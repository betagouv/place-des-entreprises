# == Schema Information
#
# Table name: diagnoses
#
#  id                   :bigint(8)        not null, primary key
#  completed_at         :datetime
#  content              :text
#  happened_on          :date
#  retention_email_sent :boolean          default(FALSE)
#  step                 :integer          default("not_started")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  advisor_id           :bigint(8)
#  facility_id          :bigint(8)        not null
#  solicitation_id      :bigint(8)
#  visitee_id           :bigint(8)
#
# Indexes
#
#  index_diagnoses_on_advisor_id       (advisor_id)
#  index_diagnoses_on_facility_id      (facility_id)
#  index_diagnoses_on_solicitation_id  (solicitation_id)
#  index_diagnoses_on_visitee_id       (visitee_id)
#
# Foreign Keys
#
#  fk_rails_...  (advisor_id => users.id)
#  fk_rails_...  (facility_id => facilities.id)
#  fk_rails_...  (solicitation_id => solicitations.id)
#  fk_rails_...  (visitee_id => contacts.id)
#

class Diagnosis < ApplicationRecord
  ##
  #
  include Archivable
  include DiagnosisCreation::DiagnosisMethods

  ## Constants
  #
  enum step: { not_started: 1, contact: 2, needs: 3, matches: 4, completed: 5 }, _prefix: true

  ## Associations
  #
  belongs_to :facility, inverse_of: :diagnoses
  belongs_to :advisor, class_name: 'User', inverse_of: :sent_diagnoses, optional: true
  belongs_to :visitee, class_name: 'Contact', inverse_of: :diagnoses, optional: true
  belongs_to :solicitation, inverse_of: :diagnosis, optional: true, touch: true
  has_many :needs, dependent: :destroy, inverse_of: :diagnosis

  ## Validations and Callbacks
  #
  validate :step_needs_has_contact
  validate :step_matches_has_needs_attributes
  validate :step_completed_has_matches
  validate :step_completed_has_advisor
  validate :without_solicitation_has_advisor
  validate :only_one_solicitation

  accepts_nested_attributes_for :facility
  accepts_nested_attributes_for :needs, allow_destroy: true
  accepts_nested_attributes_for :visitee

  ## Through Associations
  #
  # :facility
  has_one :company, through: :facility, inverse_of: :diagnoses
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :diagnoses

  # :needs
  has_many :subjects, through: :needs, inverse_of: :diagnoses
  has_many :themes, through: :subjects, inverse_of: :diagnoses
  has_many :matches, through: :needs, inverse_of: :diagnosis

  # :matches
  has_many :experts, through: :matches, inverse_of: :received_diagnoses

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_diagnoses
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_diagnoses

  # :expert
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_diagnoses
  has_many :expert_institutions, through: :experts, source: :institution, inverse_of: :received_diagnoses
  has_many :contacted_users, through: :experts, source: :users, inverse_of: :received_diagnoses

  ## Callbacks
  #
  after_update :update_needs, if: :step_completed?

  ## Scopes
  #
  scope :from_solicitation, -> { where.not(solicitation: nil) }
  scope :from_visit, -> { where(solicitation: nil) }
  scope :in_progress, -> { where.not(step: :completed) }
  scope :completed, -> { where(step: :completed) }
  scope :available_for_expert, -> (expert) do
    joins(needs: [matches: [:expert]])
      .where(needs: { matches: { experts: { id: expert.id } } })
  end

  scope :after_step, -> (minimum_step) { where('step >= ?', minimum_step) }

  scope :min_closed_at, -> (range) do
    joins(:matches)
      .merge(Match.status_done)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  ## Scopes for flags
  #
  FLAGS = %i[retention_email_sent satisfaction_email_sent]
  FLAGS.each do |flag|
    scope flag, -> { where(flag => true) }
    scope "not_#{flag}", -> { where(flag => false) }
  end

  ##
  #
  def only_one_solicitation
    if self.solicitation.present? && Diagnosis.joins(:solicitation).where(solicitations: { id: self.solicitation.id }).reject { |d| d == self }.present?
      self.errors.add(:solicitation, I18n.t('activerecord.errors.models.diagnosis.attributes.solicitation.has_already_a_diagnosis'))
    end
  end

  def to_s
    "#{company.name} (#{I18n.l display_date})"
  end

  def display_date
    happened_on || created_at.to_date
  end

  def from_solicitation?
    solicitation_id.present?
  end

  def from_visit?
    solicitation_id.nil?
  end

  ## Matching
  #
  def notify_matches_made!
    # Notify experts
    self.matches.update_all(sent_at: Time.zone.now)
    experts.each do |expert|
      self.needs.each do |need|
        ExpertMailer.with(expert: expert, need: need).notify_company_needs.deliver_later
      end
      expert.first_notification_help_email
    end
  end

  def subject_title
    if solicitation.present?
      solicitation.landing_subject.title
    else
      needs.first.subject.label
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "advisor_id", "archived", "completed_at", "content", "created_at", "facility_id", "happened_on", "id",
      "id_value", "retention_email_sent", "solicitation_id", "step", "updated_at", "visitee_id"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "advisor", "advisor_antenne", "advisor_institution", "company", "contacted_users", "expert_antennes",
      "expert_institutions", "experts", "facility", "facility_territories", "matches", "needs", "solicitation", "subjects",
      "themes", "visitee"
    ]
  end

  private

  def update_needs
    needs.each { |n| n.update_status }
  end

  def step_needs_has_contact
    if step_needs?
      errors.add(:visitee, :blank) if visitee.nil?
      errors.add(:happened_on, :blank) if happened_on.nil?
    end
  end

  def step_matches_has_needs_attributes
    if step_matches? && needs.blank?
      errors.add(:needs, :blank)
    end
  end

  def step_completed_has_matches
    # NOTE: we can’t rely on `self.matches` (a :through association) before the objects are actually saved
    # On regarde qu'il n'y ait aucun besoin sans match
    if step_completed? && (needs.empty? || needs&.map(&:matches)&.any?{ |m| m.empty? })
      errors.add(:base, :cant_send_need_without_matches)
    end
  end

  def step_completed_has_advisor
    if step_completed? && advisor.nil?
      errors.add(:advisor, :blank)
    end
  end

  def without_solicitation_has_advisor
    if solicitation.nil? && advisor.nil?
      errors.add(:advisor, :blank)
    end
  end
end

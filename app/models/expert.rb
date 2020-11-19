# == Schema Information
#
# Table name: experts
#
#  id                   :bigint(8)        not null, primary key
#  deleted_at           :datetime
#  email                :string
#  flags                :jsonb
#  full_name            :string
#  is_global_zone       :boolean          default(FALSE)
#  phone_number         :string
#  reminders_notes      :text
#  role                 :string
#  subjects_reviewed_at :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  antenne_id           :bigint(8)        not null
#
# Indexes
#
#  index_experts_on_antenne_id  (antenne_id)
#  index_experts_on_deleted_at  (deleted_at)
#  index_experts_on_email       (email)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#

class Expert < ApplicationRecord
  include PersonConcern
  include InvolvementConcern
  include SoftDeletable

  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :direct_experts
  include ManyCommunes

  audited only: :subjects_reviewed_at
  has_associated_audits

  belongs_to :antenne, inverse_of: :experts

  has_and_belongs_to_many :users, inverse_of: :experts

  # Same as :users, but excluding deleted users; this makes it possible to preload not_deleted users in views.
  has_and_belongs_to_many :not_deleted_users, -> { not_deleted }, class_name: 'User'

  has_many :experts_subjects, dependent: :destroy, inverse_of: :expert
  has_many :received_matches, -> { sent }, class_name: 'Match', inverse_of: :expert, dependent: :nullify

  ## Validations
  #
  before_validation :fix_flag_values
  validates :antenne, presence: true
  validates :email, :phone_number, presence: true, unless: :deleted?
  validates_associated :experts_subjects, on: :import

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :direct_experts

  # :antenne
  has_one :institution, through: :antenne, source: :institution, inverse_of: :experts
  has_many :antenne_communes, through: :antenne, source: :communes, inverse_of: :antenne_experts
  has_many :antenne_territories, -> { distinct }, through: :antenne, source: :territories, inverse_of: :antenne_experts

  # :received_matches
  has_many :received_needs, through: :received_matches, source: :need, inverse_of: :experts
  has_many :received_diagnoses, through: :received_matches, source: :diagnosis, inverse_of: :experts

  # :experts_subjects
  has_many :institutions_subjects, through: :experts_subjects, inverse_of: :experts
  has_many :subjects, through: :experts_subjects, inverse_of: :experts

  ##
  #
  accepts_nested_attributes_for :users, allow_destroy: true
  accepts_nested_attributes_for :experts_subjects, allow_destroy: true

  ## Scopes
  #
  scope :support_experts, -> do
    joins(:subjects)
      .where({ subjects: { is_support: true } })
  end

  ## Keys for flags
  #
  FLAGS = %i[
    can_edit_own_subjects
  ]
  store_accessor :flags, FLAGS.map(&:to_s)

  def fix_flag_values
    self.flags.transform_values!(&:to_b)
  end

  # Team stuff
  scope :personal_skillsets, -> do
    # Experts with only one member only represent this user’s skills.
    single_member = Expert.unscoped.joins(:users)
      .merge(User.unscoped.not_deleted)
      .group(:id)
      .having("COUNT(users.id)=1")

    joins(:users)
      .where(id: single_member)
      .where("users.email = experts.email")
  end

  scope :only_expert_of_user, -> do
    joins(:users)
      .where(users: { id: User.unscoped.single_expert })
  end

  scope :without_users, -> do
    # Experts without members can’t connect to the app.
    # This is not a normal state, but can happen during referencing
    # before users are actually registered, or when a user is removed.
    left_outer_joins(:users)
      .merge(User.unscoped.not_deleted)
      .where(users: { id: nil })
  end

  scope :teams, -> do
    # Experts (with members) that are not personal_skillsets are proper teams
    where.not(id: Expert.unscoped.without_users)
      .where.not(id: Expert.unscoped.personal_skillsets)
  end

  # Activity stuff
  scope :with_active_matches, -> do
    joins(:received_matches)
      .merge(Match.active)
      .distinct
  end

  scope :with_active_abandoned_matches, -> do
    joins(:received_matches)
      .merge(Match.active_abandoned)
      .distinct
  end

  # Referencing
  scope :ordered_by_institution, -> do
    joins(:antenne, :institution)
      .select('experts.*', 'antennes.name', 'institutions.name')
      .order('institutions.name', 'antennes.name', :full_name)
  end

  scope :with_custom_communes, -> do
    # The naive “joins(:communes).distinct” is way more complex.
    where('EXISTS (SELECT * FROM communes_experts WHERE communes_experts.expert_id = experts.id)')
  end
  scope :without_custom_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  scope :with_global_zone, -> do
    where(is_global_zone: true)
  end

  scope :without_subjects, -> do
    left_outer_joins(:experts_subjects)
      .where(experts_subjects: { id: nil })
  end

  scope :with_subjects, -> do
    left_outer_joins(:experts_subjects)
      .where.not(experts_subjects: { id: nil })
      .distinct
  end

  scope :relevant_for_skills, -> do
    not_deleted.where(id: unscoped.teams)
      .or(not_deleted.where(id: unscoped.only_expert_of_user))
      .or(not_deleted.where(id: unscoped.with_subjects))
  end

  scope :omnisearch, -> (query) do
    joins(:antenne)
      .where('experts.full_name ILIKE ?', "%#{query}%")
      .or(Expert.joins(:antenne).where('antennes.name ILIKE ?', "%#{query}%"))
  end

  ## Team stuff
  def personal_skillset?
    not_deleted_users.size == 1 &&
      not_deleted_users.first.email == self.email
  end

  def without_users?
    not_deleted_users.empty?
  end

  def team?
    !without_users? && !personal_skillset?
  end

  ## Referencing
  def custom_communes?
    communes.any?
  end

  def without_subjects?
    experts_subjects.empty?
  end

  def should_review_subjects?
    can_edit_own_subjects &&
      (subjects_reviewed_at.nil? || subjects_reviewed_at < 6.months.ago)
  end

  def mark_subjects_reviewed!
    update subjects_reviewed_at: Time.zone.now
  end

  def first_notification_help_email
    return unless received_matches.count == 1
    ExpertMailer.first_notification_help(self).deliver_later
  end

  ## Soft deletion
  #
  def full_name
    deleted? ? I18n.t('deleted_account.full_name') : self[:full_name]
  end

  def delete
    update_columns(deleted_at: Time.zone.now,
                   email: nil,
                   full_name: nil,
                   phone_number: nil)
  end

  ## Reminders
  #
  def reminders_needs_to_call_back
    query = self.received_needs
      .status_quo
      .where.not(matches: received_matches.status_not_for_me)
      .archived(false)
      .left_outer_joins(:reminders_actions)
      .distinct
    query.exclude_needs_with_reminders_action(:recall)
  end
end

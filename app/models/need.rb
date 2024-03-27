# == Schema Information
#
# Table name: needs
#
#  id                      :bigint(8)        not null, primary key
#  abandoned_email_sent    :boolean          default(FALSE)
#  content                 :text
#  matches_count           :integer
#  retention_sent_at       :datetime
#  satisfaction_email_sent :boolean          default(FALSE), not null
#  starred_at              :datetime
#  status                  :enum             default("diagnosis_not_complete"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  diagnosis_id            :bigint(8)        not null
#  subject_id              :bigint(8)        not null
#
# Indexes
#
#  index_needs_on_diagnosis_id                 (diagnosis_id)
#  index_needs_on_status                       (status)
#  index_needs_on_subject_id                   (subject_id)
#  index_needs_on_subject_id_and_diagnosis_id  (subject_id,diagnosis_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (diagnosis_id => diagnoses.id)
#  fk_rails_...  (subject_id => subjects.id)
#

class Need < ApplicationRecord
  ##
  #
  include PgSearch::Model
  include Archivable
  include RangeScopes

  enum status: {
    diagnosis_not_complete: 'diagnosis_not_complete',
      quo: 'quo',
      taking_care: 'taking_care',
      done: 'done',
      done_no_help: 'done_no_help',
      done_not_reachable: 'done_not_reachable',
      not_for_me: 'not_for_me'
  }, _prefix: true

  paginates_per 25

  ## Associations
  #
  belongs_to :diagnosis, inverse_of: :needs, touch: true
  belongs_to :subject, inverse_of: :needs
  has_many :matches, dependent: :destroy, inverse_of: :need
  has_many :feedbacks, -> { where(category: :need) }, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminder_feedbacks, -> { where(category: :need_reminder) }, class_name: :Feedback, dependent: :destroy, as: :feedbackable, inverse_of: :feedbackable
  has_many :reminders_actions, inverse_of: :need, dependent: :destroy
  has_one :company_satisfaction, dependent: :destroy, inverse_of: :need
  has_many :institution_filters, dependent: :destroy, as: :institution_filtrable, inverse_of: :institution_filtrable
  has_many :badge_badgeables, as: :badgeable
  has_many :badges, through: :badge_badgeables, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update

  ## Validations
  #
  validates :subject, uniqueness: { scope: :diagnosis_id }

  accepts_nested_attributes_for :matches, allow_destroy: true
  accepts_nested_attributes_for :institution_filters, allow_destroy: false

  ## Callbacks
  #
  after_touch :update_status

  ## Through Associations
  #
  # :diagnosis
  has_one :facility, through: :diagnosis, inverse_of: :needs
  has_one :company, through: :diagnosis, inverse_of: :needs
  has_one :solicitation, through: :diagnosis, inverse_of: :needs
  has_one :advisor, through: :diagnosis, inverse_of: :sent_needs
  has_one :visitee, through: :diagnosis, inverse_of: :needs

  # :matches
  has_many :experts, -> { distinct }, through: :matches, inverse_of: :received_needs

  # :facility
  has_many :facility_territories, through: :facility, source: :territories, inverse_of: :needs
  has_many :facility_regions, -> { regions }, through: :facility, source: :territories, inverse_of: :matches

  # :advisor
  has_one :advisor_antenne, through: :advisor, source: :antenne, inverse_of: :sent_needs
  has_one :advisor_institution, through: :advisor, source: :institution, inverse_of: :sent_needs

  # :experts
  has_many :expert_antennes, through: :experts, source: :antenne, inverse_of: :received_needs
  has_many :expert_institutions, through: :experts, source: :institution, inverse_of: :received_needs
  has_many :contacted_users, through: :experts, source: :users, inverse_of: :received_needs

  # :subject
  has_one :theme, through: :subject, inverse_of: :needs

  ## Scopes
  #
  NO_ACTIVITY_DELAY = 14.days
  ARCHIVE_DELAY = 6.months
  REMINDERS_DAYS = {
    poke: 9,
    last_chance: 21,
    abandon: 45
  }

  pg_search_scope :omnisearch,
                  against: [:content],
                  associated_against: {
                    visitee: [:full_name, :email],
                    company: [:name, :siren],
                    facility: :readable_locality,
                    subject: :label
                  },
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  scope :ordered_for_interview, -> do
    left_outer_joins(:subject)
      .merge(Subject.ordered_for_interview)
  end

  scope :diagnosis_completed, -> { where.not(status: :diagnosis_not_complete) }

  scope :reminders_to, -> (action) do
    if action == :refused
      diagnosis_completed
        .where(status: :not_for_me)
        .without_action(action)

    else # :poke and :last_chance
      diagnosis_completed
        .status_quo
        .in_reminders_range(action)
        .without_action(action)
    end
  end

  scope :without_action, -> (category) do
    subquery = Need.unscoped
      .joins(:reminders_actions)
      .where(reminders_actions: { category: category })
    where.not(id: subquery)
  end

  scope :with_action, -> (category) do
    joins(:reminders_actions)
      .where(reminders_actions: { category: category })
  end

  scope :received_by, -> (user_id) do
    joins(:contacted_users).where(users: { id: user_id })
  end

  def self.reminders_range(action)
    index = REMINDERS_DAYS.keys.index(action)
    Range.new(REMINDERS_DAYS.values[index + 1]&.days&.ago, REMINDERS_DAYS.values[index].days.ago)
  end

  scope :in_reminders_range, -> (action) {
    range = reminders_range(action)
    matches_sent_at(range)
  }

  scope :matches_sent_at, -> (range) {
    needs_in_range = Need.unscoped
      .joins(:matches)
      .where(matches: { sent_at: range })
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_in_range)
  }

  scope :min_closed_at, -> (range) do
    joins(:matches)
      .merge(Match.status_done)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  scope :min_closed_with_help_at, -> (range) do
    joins(:matches)
      .merge(Match.with_exchange)
      .group(:id)
      .having("MIN(matches.closed_at) BETWEEN ? AND ?", range.begin, range.end)
  end

  # For Reminders, find Needs without taking care since NO_ACTIVITY_DELAY
  scope :no_activity, -> { joins(:matches).where("matches.created_at < ?", NO_ACTIVITY_DELAY.ago) }

  scope :with_some_matches_in_status, -> (status) do
    # status can be an array
    needs_with_matches = Need.unscoped
      .joins(:matches)
      .where(matches: Match.unscoped.where(status: status))
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_with_matches)
  end

  scope :with_matches_only_in_status, -> (status) do
    # status can be an array
    needs_with_matches = Need.unscoped
      .left_outer_joins(:matches)
      .where.not(matches: Match.unscoped.where.not(status: status))
    # put it in a subquery to avoid duplicate rows, or requiring the join if this scope is composed with others
    where(id: needs_with_matches)
  end

  # Veille : besoins hors relances avec des MER en attente
  scope :with_filtered_matches_quo, -> do
    range = Range.new(REMINDERS_DAYS[:abandon].days.ago, REMINDERS_DAYS[:last_chance].days.ago)
    relance_experts = Expert.in_reminders_registers
    quo_matches = Match.sent
      .status_quo
      .where(sent_at: range)
      .where.not(expert: relance_experts)
    quo_matches_needs = Need.diagnosis_completed.joins(:matches)
      .where(matches: quo_matches)
      .where.not(status: :quo) # besoins dans panier relance
      .without_action(:quo_match)
    where(id: quo_matches_needs)
  end

  scope :starred, -> do
    where.not(starred_at: nil)
      .without_action(:starred_need)
  end

  # Utilisé pour les mails de relance
  scope :active, -> do
    with_matches_only_in_status([:quo, :taking_care, :not_for_me])
      .with_some_matches_in_status([:quo, :taking_care])
  end

  scope :without_exchange, -> do
    where(status: [:not_for_me, :done_not_reachable, :quo, :taking_care])
  end

  scope :for_reminders, -> do
    where(status: [:quo, :done_no_help, :done_not_reachable])
  end

  scope :with_exchange, -> do
    where(status: [:done, :done_no_help])
  end

  scope :in_progress, -> do
    where(status: [:quo, :taking_care])
  end

  scope :done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable, :not_for_me])
  end

  scope :with_status_done, -> do
    where(status: [:done, :done_no_help, :done_not_reachable])
  end

  scope :taken_care_of, -> do
    where(status: [:done, :done_no_help, :done_not_reachable, :taking_care])
  end

  scope :quo_active, -> do
    range = Range.new(Need::REMINDERS_DAYS[:abandon]&.days&.ago, nil)
    status_quo.matches_sent_at(range)
  end

  scope :expired, -> do
    range = Range.new(nil, Need::REMINDERS_DAYS[:abandon]&.days&.ago)
    status_quo.matches_sent_at(range)
  end

  scope :for_facility, -> (facility) do
    joins(diagnosis: :facility).where(diagnoses: { facility: facility })
  end

  scope :with_siret, -> do
    joins(diagnosis: :facility).merge(Facility.with_siret)
  end

  scope :for_emails_and_sirets, -> (emails, sirets = []) do
    Need
      .diagnosis_completed
      .joins('
        INNER JOIN "diagnoses" ON "diagnoses"."id" = "needs"."diagnosis_id"
        INNER JOIN "facilities" ON "facilities"."id" = "diagnoses"."facility_id"
        INNER JOIN "solicitations" ON "solicitations"."id" = "diagnoses"."solicitation_id"
      ')
      .where(solicitations: { email: emails })
      .or(Need.diagnosis_completed.where(diagnosis: { facilities: { siret: sirets.compact } }))
  end

  scope :in_antenne_perimeters, -> (antenne) do
    where(id: antenne.perimeter_received_needs)
  end

  scope :by_region, -> (region_id) do
    joins(facility: :commune).merge(Commune.by_region(region_id))
  end

  scope :by_subject, -> (subject_id) do
    where(subject_id: subject_id)
  end

  scope :by_antenne, -> (antenne_id) do
    joins(matches: { expert: :antenne }).merge(Match.by_antenne(antenne_id))
  end

  scope :created_since, -> (date) do
    where(created_at: Date.new(*date.split('-').map(&:to_i)).beginning_of_day..)
  end

  scope :created_until, -> (date) do
    where(created_at: ..Date.new(*date.split('-').map(&:to_i)).end_of_day)
  end

  scope :in_antennes_perimeters, -> (antennes) do
    Need.where(id: antennes.map(&:perimeter_received_needs).flatten)
  end

  def self.apply_filters(params)
    klass = self
    klass = klass.by_region(params[:by_region]) if params[:by_region].present?
    klass = klass.by_subject(params[:by_subject]) if params[:by_subject].present?
    # with_pg_search_rank : pour contrer erreur sur le distinct.
    # Cf https://github.com/Casecommons/pg_search/issues/238
    klass = klass.omnisearch(params[:omnisearch]).with_pg_search_rank if params[:omnisearch].present?
    klass = klass.created_since(params[:created_since]) if params[:created_since].present?
    klass = klass.created_until(params[:created_until]) if params[:created_until].present?
    klass = klass.by_antenne(params[:antenne_id]) if params[:antenne_id].present?
    klass.all
  end

  ##
  #
  def to_s
    "#{company} : #{subject}"
  end

  def initial_matches_at
    matches.pluck(:created_at).min
  end

  def no_activity?
    updated_at < NO_ACTIVITY_DELAY.ago
  end

  def has_action?(action)
    reminders_actions.find_by(category: action).present?
  end

  def action_date(action)
    reminders_actions.where(category: action).pluck(:created_at).min
  end

  def is_abandoned?
    has_action?('abandon')
  end

  def starred?
    !starred_at.nil?
  end

  def quo_experts
    Expert.joins(:received_matches).merge(matches.status_quo)
  end

  def update_status
    self.matches.reload # Make sure the matches are fresh from DB; see #1421
    new_status = computed_status
    self.update(status: new_status)
  end

  def display_time
    solicitation&.completed_at || diagnosis.created_at
  end

  def display_date
    display_time.to_date
  end

  def computed_status
    matches_status = matches.pluck(:status).map(&:to_sym)

    # no matches yet
    if matches.empty? || !diagnosis.step_completed?
      :diagnosis_not_complete

    # at least one match done:
    elsif matches_status.include?(:done)
      :done
    elsif matches_status.include?(:done_no_help)
      :done_no_help
    elsif matches_status.include?(:done_not_reachable)
      :done_not_reachable

    # at least one match not closed
    elsif matches_status.include?(:taking_care)
      :taking_care
    elsif matches_status.include?(:quo)
      :quo

    # all matches rejected
    else
      :not_for_me
    end
  end

  def touch_after_badges_update(_badge)
    touch if persisted?
  end

  def self.ransackable_attributes(auth_object = nil)
    [
      "abandoned_email_sent", "archived", "content", "created_at", "diagnosis_id", "id", "id_value", "matches_count",
      "retention_sent_at", "satisfaction_email_sent", "status", "subject_id", "updated_at"
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "advisor", "advisor_antenne", "advisor_institution", "badge_badgeables", "badges", "company", "company_satisfaction",
      "contacted_users", "diagnosis", "expert_antennes", "expert_institutions", "experts", "facility", "facility_regions",
      "facility_territories", "feedbacks", "institution_filters", "matches", "reminder_feedbacks", "reminders_actions",
      "solicitation", "subject", "theme", "visitee"
    ]
  end
end

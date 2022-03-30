# == Schema Information
#
# Table name: solicitations
#
#  id                               :bigint(8)        not null, primary key
#  banned                           :boolean          default(FALSE)
#  code_region                      :integer
#  created_in_deployed_region       :boolean          default(FALSE)
#  description                      :string
#  email                            :string
#  form_info                        :jsonb
#  full_name                        :string
#  landing_slug                     :string
#  location                         :string
#  phone_number                     :string
#  prepare_diagnosis_errors_details :jsonb
#  requested_help_amount            :string
#  siret                            :string
#  status                           :enum             default("in_progress"), not null
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  institution_id                   :bigint(8)
#  landing_id                       :bigint(8)
#  landing_subject_id               :bigint(8)
#
# Indexes
#
#  index_solicitations_on_code_region         (code_region)
#  index_solicitations_on_email               (email)
#  index_solicitations_on_institution_id      (institution_id)
#  index_solicitations_on_landing_id          (landing_id)
#  index_solicitations_on_landing_slug        (landing_slug)
#  index_solicitations_on_landing_subject_id  (landing_subject_id)
#  index_solicitations_on_status              (status)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#  fk_rails_...  (landing_id => landings.id)
#  fk_rails_...  (landing_subject_id => landing_subjects.id)
#

class Solicitation < ApplicationRecord
  include AASM
  include DiagnosisCreation::SolicitationMethods
  include RangeScopes

  enum status: { in_progress: 'in_progress', processed: 'processed', canceled: 'canceled' }, _prefix: true

  aasm column: :status, enum: true do
    state :in_progress, initial: true
    state :processed
    state :canceled

    event :cancel do
      # une solicitation peut être doublement canceled : "mauvais siret" qui se transforme en "hors région"
      transitions from: [:in_progress, :processed, :canceled], to: :canceled
    end

    event :process do
      transitions from: [:in_progress, :processed, :canceled], to: :processed, if: :diagnosis_completed?
    end
  end

  def diagnosis_completed?
    self.diagnosis.step_completed?
  end

  paginates_per 50

  ## Associations
  #
  belongs_to :landing, inverse_of: :solicitations, optional: true
  belongs_to :landing_subject, inverse_of: :solicitations, optional: true
  has_one :landing_theme, through: :landing_subject, source: :landing_theme, inverse_of: :landing_subjects

  has_one :diagnosis, inverse_of: :solicitation
  has_many :diagnosis_regions, -> { regions }, through: :diagnosis, source: :facility_territories, inverse_of: :diagnoses
  has_one :facility, through: :diagnosis, source: :facility, inverse_of: :diagnoses

  has_many :feedbacks, as: :feedbackable, dependent: :destroy
  has_many :matches, through: :diagnosis, inverse_of: :solicitation
  has_many :needs, through: :diagnosis, inverse_of: :solicitation
  has_and_belongs_to_many :badges, -> { distinct }, after_add: :touch_after_badges_update, after_remove: :touch_after_badges_update
  belongs_to :institution, inverse_of: :solicitations, optional: true

  before_create :set_institution_from_landing
  before_create :format_solicitation

  ## Callbacks
  #
  def set_institution_from_landing
    self.institution ||= landing&.institution || Institution.find_by(slug: form_info&.fetch('institution', nil))
  end

  def touch_after_badges_update(_badge)
    touch if persisted?
  end

  def format_solicitation
    params = set_siret_and_region
    params.merge!(format_email)
    SolicitationModification::Update.new(self, params).call
  end

  def format_email
    # cas des double point qui empêche l'envoi d'email
    return { email: self.email.squeeze('.') }
  end

  def set_siret_and_region
    return {} if code_region.present?
    params = { code_region: self.code_region, siret: self.siret }
    siret_or_siren = FormatSiret.clean_siret(siret)
    # Solicitation with a valid SIRET
    if FormatSiret.siret_is_valid(siret_or_siren)
      begin
        etablissement_data = ApiEntreprise::Etablissement::Base.new(siret_or_siren).call
        return if etablissement_data.blank?
        params[:code_region] = ApiConsumption::Models::Facility.new(etablissement_data).code_region
        params[:siret] = siret_or_siren
      rescue ApiEntreprise::ApiEntrepriseError => e
        return params
      end
    # Solicitation with a valid SIREN
    elsif FormatSiret.siren_is_valid(siret_or_siren)
      response = ApiSirene::SirenSearch.search(siret_or_siren)
      return if (!response.success? || response.other_etablissements_sirets.present?)
      params[:code_region] = response.siege_social[:region_siege]
      params[:siret] = response.siege_social[:siret]
    end
    params
  end

  ## Validations
  #
  validates :landing, :description, presence: true, allow_blank: false
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  validate on: :create do
    # All visible fields are required on creation
    required_fields.each do |attr|
      errors.add(attr, :blank) if self.public_send(attr).blank?
    end
  end

  ## Scopes
  #
  scope :omnisearch, -> (query) do
    if query.present?
      where(id: have_badge(query))
        .or(where(id: have_landing_subject(query)))
        .or(where(id: have_landing_theme(query)))
        .or(where(id: have_landing(query)))
        .or(description_contains(query))
        .or(name_contains(query))
        .or(email_contains(query))
        .or(pk_kwd_contains(query))
        .or(pk_campaign_contains(query))
    end
  end

  scope :have_badge, -> (query) do
    joins(:badges).where('badges.title ILIKE ?', "%#{query}%")
  end

  scope :have_landing_subject, -> (query) do
    joins(:landing_subject).where('landing_subjects.slug ILIKE ?', "%#{query}%")
  end

  scope :have_landing_theme, -> (query) do
    joins(:landing_theme).where('landing_themes.slug ILIKE ?', "%#{query}%")
  end

  scope :have_landing, -> (query) do
    joins(:landing).where('landings.slug ILIKE ?', "%#{query}%")
  end

  scope :description_contains, -> (query) do
    where('solicitations.description ILIKE ?', "%#{query}%")
  end

  scope :name_contains, -> (query) do
    where('solicitations.full_name ILIKE ?', "%#{query}%")
  end

  scope :email_contains, -> (query) do
    where('solicitations.email ILIKE ?', "%#{query}%")
  end

  scope :pk_kwd_contains, -> (query) {
    where("solicitations.form_info::json->>'pk_kwd' ILIKE ?", "%#{query}%")
  }

  scope :pk_campaign_contains, -> (query) {
    where("solicitations.form_info::json->>'pk_campaign' ILIKE ?", "%#{query}%")
  }

  scope :without_diagnosis, -> {
    left_outer_joins(:diagnosis)
      .where(diagnoses: { id: nil })
  }

  # /!\ Fonctionne pas tout à fait, des solicitations avec matches ressortent (une vingtaine)
  scope :without_matches, -> {
    left_outer_joins(:matches)
      .where(matches: { id: nil })
  }

  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }

  scope :in_regions, -> (codes_regions) do
    where(code_region: codes_regions)
  end

  scope :in_deployed_regions, -> do
    where(created_in_deployed_region: true)
  end

  # solicitation avec region identifiee mais hors region deployee
  scope :in_undeployed_regions, -> do
    where(created_in_deployed_region: false).where.not(code_region: nil)
  end

  scope :out_of_regions, -> (codes_regions) do
    where.not(code_region: codes_regions).where.not(code_region: nil)
  end

  scope :in_unknown_region, -> { where(code_region: nil) }

  # scope destiné à recevoir les solicitations qui ne sortent pas
  # dans les autres filtres des solicitation.
  # La méthode d'identification pourra evoluer au fil du temps
  scope :uncategorisable, -> { in_unknown_region }

  # param peut être un id de Territory ou une clé correspondant à un scope ("uncategorisable" par ex)
  scope :by_possible_region, -> (param) {
    begin
      in_regions(Territory.find(param).code_region)
    rescue ActiveRecord::RecordNotFound => e
      self.send(param)
    end
  }

  scope :out_of_deployed_territories, -> {
    out_of_regions(Territory.deployed_codes_regions)
  }

  # Solicitations similaires
  #
  scope :from_same_company, -> (solicitation) {
    where(siret: solicitation.valid_sirets)
      .or(where(email: solicitation.email))
  }

  scope :banned, -> { where(banned: true) }

  GENERIC_EMAILS_TYPES = %i[bad_quality bad_quality_difficulties out_of_region employee_labor_law particular_retirement creation siret moderation independent_tva intermediary recruitment_foreign_worker]

  def doublon_solicitations
    Solicitation.where(status: [:in_progress])
      .where.not(id: self.id)
      .from_same_company(self)
      .uniq
  end

  def from_banned_company?
    banned? || Solicitation.from_same_company(self).banned.any?
  end

  def recent_matched_solicitations
    Solicitation.processed
      .where.not(id: self.id)
      .created_between(3.weeks.ago, Time.zone.now)
      .where(landing_subject_id: self.landing_subject_id)
      .from_same_company(self)
      .uniq
  end

  # Trouver les sirets probables des solicitations pour identifier relances et doublons
  def valid_sirets
    sirets = []
    sirets << self.facility.siret if self.facility.present?

    clean_siret = FormatSiret.clean_siret(self.siret)
    sirets << clean_siret if FormatSiret.siret_is_valid(clean_siret)

    contact = Contact.find_by(email: self.email)
    sirets << contact.company.facilities.pluck(:siret) if contact.present?
    sirets.flatten.compact.uniq
  end

  ## JSON Accessors
  #
  FORM_INFO_KEYS = %i[pk_campaign pk_kwd gclid]
  store_accessor :form_info, FORM_INFO_KEYS.map(&:to_s)

  ##
  # Development helper
  def self.new(attributes = nil, &block)
    record = super
    if Rails.env.development? && ENV['DEVELOPMENT_PREFILL_SOLICITATION_FORM'].to_b
      record.assign_attributes(
        description: 'Ceci est un test',
        siret: '200 054 948 00019',
        full_name: 'Marie Dupont',
        phone_number: '01 23 46 78 90',
        email: 'marie.dupont@exemple.fr'
      )
    end
    record
  end

  ## Visible fields in form
  #
  BASE_REQUIRED_FIELDS = %i[full_name phone_number email]
  DEFAULT_REQUIRED_FIELDS = %i[full_name phone_number email siret]

  def required_fields
    if landing_subject.present?
      BASE_REQUIRED_FIELDS + landing_subject&.required_fields
    else
      DEFAULT_REQUIRED_FIELDS
    end
  end

  FIELD_TYPES = {
    full_name: 'text',
    phone_number: 'tel',
    email: 'email',
    siret: 'text',
    requested_help_amount: 'text',
    location: 'text'
  }

  ## Preselection
  #
  def preselected_subject
    landing_subject&.subject
  end

  def normalized_phone_number
    number = phone_number&.gsub(/[^0-9]/,'')
    if number.present? && number.length == 10
      number.gsub(/(.{2})(?=.)/, '\1 \2')
    else
      phone_number
    end
  end

  # Provenance
  #
  def provenance_category
    if landing&.iframe?
      :iframe
    elsif pk_campaign&.start_with?('googleads-')
      :googleads
    elsif pk_campaign.present?
      :campaign
    end
  end

  def from_iframe?
    provenance_category == :iframe
  end

  def from_pk_campaign?
    provenance_category == :campaign || provenance_category == :googleads
  end

  def provenance_title
    if from_iframe?
      landing.slug
    elsif from_pk_campaign?
      pk_campaign
    end
  end

  def provenance_detail
    pk_kwd
  end

  # Else ---------------------
  def to_s
    "#{self.class.model_name.human} #{id}"
  end

  def display_attributes
    %i[normalized_phone_number institution requested_help_amount location pk_campaign pk_kwd]
  end

  def normalized_siret
    siret.gsub(/(\d{3})(\d{3})(\d{3})(\d*)/, '\1 \2 \3 \4')
  end

  def transmitted_at
    diagnosis&.completed_at
  end

  def region
    return if code_region.nil?
    Territory.find_by(code_region: self.code_region)
  end
end

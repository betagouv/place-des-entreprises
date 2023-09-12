# == Schema Information
#
# Table name: experts_subjects
#
#  id                     :bigint(8)        not null, primary key
#  intervention_criteria  :string
#  expert_id              :bigint(8)
#  institution_subject_id :bigint(8)
#
# Indexes
#
#  index_experts_subjects_on_expert_id                             (expert_id)
#  index_experts_subjects_on_expert_id_and_institution_subject_id  (expert_id,institution_subject_id) UNIQUE
#  index_experts_subjects_on_institution_subject_id                (institution_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#  fk_rails_...  (institution_subject_id => institutions_subjects.id)
#

class ExpertSubject < ApplicationRecord
  include WithSubject

  ## Associations
  #
  belongs_to :expert, inverse_of: :experts_subjects
  belongs_to :institution_subject, inverse_of: :experts_subjects

  ## "Through" associations
  #
  has_one :subject, through: :institution_subject, inverse_of: :experts_subjects
  has_one :theme, through: :subject, inverse_of: :experts_subjects
  has_many :match_filters, through: :expert, inverse_of: :experts_subjects

  belongs_to :not_deleted_expert, -> { not_deleted }, class_name: 'Expert', foreign_key: 'expert_id', optional: true, inverse_of: :experts_subjects

  ## Validations
  #
  validates :expert, uniqueness: { scope: :institution_subject_id }

  ## Scopes
  #
  scope :relevant_for, -> (need) do
    of_subject(need.subject)
      .joins(:not_deleted_expert)
      .in_commune(need.facility.commune)
  end

  scope :of_subject, -> (subject) do
    joins(:institution_subject)
      .where(institutions_subjects: { subject: subject })
  end

  scope :in_commune, -> (commune) do
    where(expert: commune.all_experts)
  end

  scope :of_institution, -> (institution) do
    joins(institution_subject: :institution)
      .where(institutions_subjects: { institution: institution })
  end

  scope :not_of_institution, -> (institution) do
    joins(institution_subject: :institution)
      .where.not(institutions_subjects: { institution: institution })
  end

  scope :of_antenne, -> (antenne) do
    joins(expert: :antenne)
      .where(expert: { antenne: antenne })
  end

  scope :not_of_antenne, -> (antenne) do
    joins(expert: :antenne)
      .where.not(expert: { antenne: antenne })
  end

  scope :in_company_registres, -> (company) do
    klass = self
    klass = klass.not_of_institution(Institution.find_by(slug: 'cma')) if (company.inscrit_rcs || company.activite_liberale) && !company.inscrit_rm
    klass = klass.not_of_institution(Institution.find_by(slug: 'cci')) if (company.inscrit_rm  || company.activite_liberale) && !company.inscrit_rcs
    klass = klass.not_of_institution(Institution.find_by(slug: 'unapl')) if !company.activite_liberale && Institution.find_by(slug: 'unapl').present?
    klass
  end

  scope :without_irrelevant_opcos, -> (facility) do
    relevant_opco = facility.opco
    # Si pas d'opco identifié, on n'envoie à personne
    irrelevant_opcos = Institution.opco.where.not(id: relevant_opco&.id)
    not_of_institution(irrelevant_opcos)
  end

  scope :support_for, -> (diagnosis) do
    experts_in_commune = diagnosis.facility.commune.all_experts

    support.where(expert: experts_in_commune)
  end

  scope :support, -> { where(institution_subject: InstitutionSubject.support_subjects) }

  ## used for serialization in advisors csv
  #
  def csv_description
    intervention_criteria.presence || 'x'
  end

  def csv_description=(value)
    self.intervention_criteria = if value.downcase.in? ['x', I18n.t('yes')]
      ''
    else
      value
    end
  end
end

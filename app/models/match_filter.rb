# == Schema Information
#
# Table name: match_filters
#
#  id                     :bigint(8)        not null, primary key
#  accepted_legal_forms   :string           is an Array
#  accepted_naf_codes     :string           is an Array
#  effectif_max           :integer
#  effectif_min           :integer
#  excluded_legal_forms   :string           is an Array
#  excluded_naf_codes     :string           is an Array
#  max_years_of_existence :integer
#  min_years_of_existence :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  antenne_id             :bigint(8)
#  institution_id         :bigint(8)
#
# Indexes
#
#  index_match_filters_on_antenne_id      (antenne_id)
#  index_match_filters_on_institution_id  (institution_id)
#
# Foreign Keys
#
#  fk_rails_...  (antenne_id => antennes.id)
#  fk_rails_...  (institution_id => institutions.id)
#
class MatchFilter < ApplicationRecord
  ## Associations
  #
  belongs_to :antenne, optional: true
  belongs_to :institution, optional: true
  has_and_belongs_to_many :subjects

  validate :antenne_or_institution

  has_many :antenne_experts, through: :antenne, source: :experts
  has_many :institution_experts, through: :institution, source: :experts

  def experts
    antenne.present? ? antenne_experts : institution_experts
  end

  def experts_subjects
    ExpertSubject.where(expert_id: experts.ids)
  end

  def antenne_or_institution
    if antenne.nil? && institution.nil?
      errors.add(:antenne_or_institution, :blank, message: I18n.t("activerecord.errors.models.match_filter.attributes.antenne_or_institution.blank"))
    end
    if antenne.present? && institution.present?
      errors.add(:antenne_or_institution, :invalid, message: I18n.t("activerecord.errors.models.match_filter.attributes.antenne_or_institution.invalid"))
    end
  end

  def raw_accepted_naf_codes
    accepted_naf_codes&.join(' ')
  end

  def raw_excluded_naf_codes
    excluded_naf_codes&.join(' ')
  end

  def raw_excluded_legal_forms
    excluded_legal_forms&.join(' ')
  end

  def raw_accepted_legal_forms
    accepted_legal_forms&.join(' ')
  end

  def raw_accepted_naf_codes=(naf_codes)
    updated_naf_codes = naf_codes.delete('.').split(/[,\s]/).delete_if(&:empty?)
    self.accepted_naf_codes = updated_naf_codes
  end

  def raw_excluded_naf_codes=(naf_codes)
    updated_naf_codes = naf_codes.delete('.').split(/[,\s]/).delete_if(&:empty?)
    self.excluded_naf_codes = updated_naf_codes
  end

  def raw_accepted_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.accepted_legal_forms = updated_legal_form_code
  end

  def raw_excluded_legal_forms=(legal_form_code)
    updated_legal_form_code = legal_form_code.split(/[,\s]/).delete_if(&:empty?)
    self.excluded_legal_forms = updated_legal_form_code
  end
end

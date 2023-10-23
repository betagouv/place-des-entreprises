# frozen_string_literal: true

class ExplorationEffectifs
  # Accepts string of INSEE codes separated by spaces
  def initialize
    start_date = Date.today.beginning_of_month
    end_date = Date.today
    @companies = Company
      .includes(:needs, :diagnoses).references(:needs, :diagnoses)
      .where(created_at: start_date..end_date)
      .where(facilities: { diagnoses: { step: :completed } })
      .distinct
    @facilities = Facility
      .where(created_at: start_date..end_date)
      .where(diagnoses: { step: :completed })
      .distinct
  end

  def call
    p "Nombre d'entreprises : #{@companies.count}"
    p "Nombre d'entreprises sans siren : #{companies_no_siren.count}"
    p "Nombre d'entreprises avec siren : #{companies_with_siren.count}"
    p "Nombre d'entreprises avec code effectif absent, NN ou 0 : #{companies_no_effectif.count}"
    byebug
    array = []
    companies_no_effectif.find_each do |company|
      # api_company = ApiConsumption::Company.new(company.siren).call
      # array.push([company.siren, company.effectif, company.code_effectif, api_company.effectif, api_company.code_effectif].join(','))
      array.push([company.siren, company.legal_form_code, company.effectif, company.code_effectif].join(','))
    end

    array
  end

  def companies_with_siren
    @companies_with_siren ||= @companies.where.not(siren: nil)
  end

  def companies_no_effectif
    @companies_no_effectif ||= companies_with_siren.where(code_effectif: [nil, 'NN', 0])
  end

  def companies_no_siren
    @companies_no_siren ||= @companies.where(siren: nil)
  end
end
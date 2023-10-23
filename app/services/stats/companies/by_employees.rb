module Stats::Companies
  class ByEmployees
    include ::Stats::BaseStats
    include ::Stats::FiltersStats

    def main_query
      Company
        .includes(:needs, :diagnoses).references(:needs, :diagnoses)
        .where(created_at: @start_date..@end_date)
        .where(facilities: { diagnoses: { step: :completed } })
        .distinct
    end

    def date_group_attribute
      'diagnoses.created_at'
    end

    def filtered(query)
      filtered_companies(query)
    end

    def category_group_attribute
      :code_effectif
    end

    def category_name(category)
      Effectif::CodeEffectif.new(category).simple_effectif
    end

    def category_order_attribute
      # Tweak SQL ordering: display 'NN' in the first position, before '00'
      "REPLACE(companies.code_effectif, '#{Effectif::CodeEffectif::UNITE_NON_EMPLOYEUSE}', '  ')"
    end

    def build_series
      query = main_query
      query = filtered(query)
      query = grouped_by_month(query)
      query = grouped_by_category(query)
      results = categorized_results(query)
      results = merge_categories(results)
      results = full_results(results)
      as_series(results)
    end

    def merge_categories(results)
      merged_categories = {}
      results.each do |key, value|
        new_code = I18n.t(key, scope: 'code_to_range', default: I18n.t('other')).to_s
        merged_categories[new_code] ||= {}
        merged_categories[new_code].merge!(value) { |_, o, n| o + n }
      end
      merged_categories
    end

    def all_categories
      %w[Autre 250 50 20 10 6 1 0]
    end

    def colors
      %w[#dddddd #9f3cca #F45A5B #e78112 #f3dd68 #2D908F #62e0d3 #c0ffaf]
    end

    def count
      false
    end
  end
end

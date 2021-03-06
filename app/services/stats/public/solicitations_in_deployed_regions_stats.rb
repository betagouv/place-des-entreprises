module Stats::Public
  class SolicitationsInDeployedRegionsStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.where(created_at: @start_date..@end_date)
    end

    def filtered(query)
      if territory.present?
        query = query.none
      end
      if institution.present?
        query.merge! institution.received_solicitations
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @in_deployed_regions = []
      @out_of_deployed_regions = []
      @in_unknown_region = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @in_deployed_regions.push(month_query.in_deployed_regions.where.not(code_region: nil).count)
        @out_of_deployed_regions.push(month_query.in_undeployed_regions.count)
        @in_unknown_region.push(month_query.in_unknown_region.count)
      end

      as_series(@in_deployed_regions, @out_of_deployed_regions, @in_unknown_region)
    end

    def count
      build_series
      percentage_two_numbers(@in_deployed_regions, (@out_of_deployed_regions + @in_unknown_region))
    end

    def subtitle
      I18n.t('stats.series.solicitations_in_deployed_regions.subtitle_html')
    end

    private

    def as_series(in_deployed_regions, out_of_deployed_regions, in_unknown_region)
      [
        {
          name: I18n.t('stats.in_unknown_region'),
            data: in_unknown_region
        },
        {
          name: I18n.t('stats.out_of_deployed_regions'),
            data: out_of_deployed_regions
        },
        {
          name: I18n.t('stats.in_deployed_regions'),
            data: in_deployed_regions
        }
      ]
    end
  end
end

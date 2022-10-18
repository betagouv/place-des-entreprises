module Stats::Matches
  class PositioningRate
    include ::Stats::BaseStats

    def main_query
      Match.joins(:need).where.not(need: { status: :diagnosis_not_complete })
    end

    def filtered(query)
      if territory.present?
        query.merge! query.in_region(territory)
      end
      if institution.present?
        query.merge! query.joins(expert: :institution).where(experts: { institutions: institution })
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)
      @positioning, @not_positioning = [], []
      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @positioning.push(month_query.not_status_quo.count)
        @not_positioning.push(month_query.status_quo.count)
      end

      as_series(@positioning, @not_positioning)
    end

    def count
      build_series
      percentage_two_numbers(@not_positioning, @positioning)
    end

    private

    def as_series(positioning, not_positioning)
      [
        {
          name: I18n.t('stats.not_positioning'),
          data: not_positioning
        },
        {
          name: I18n.t('stats.positioning'),
          data: positioning
        }
      ]
    end
  end
end

module Stats::Public
  class SolicitationsDiagnosesStats
    include ::Stats::BaseStats

    def main_query
      Solicitation.all
    end

    def filtered(query)
      if institution.present?
        query.merge! institution.received_solicitations
      end
      if @start_date.present?
        query = query.where("solicitations.created_at >= ? AND solicitations.created_at <= ?", @start_date, @end_date)
      end
      query
    end

    def build_series
      query = main_query
      query = filtered(query)

      @with_diagnosis = []
      @without_diagnosis = []

      search_range_by_month.each do |range|
        month_query = query.created_between(range.first, range.last)
        @with_diagnosis.push(month_query.joins(:diagnosis).count)
        @without_diagnosis.push(month_query.without_diagnosis.count)
      end

      as_series(@with_diagnosis, @without_diagnosis)
    end

    def count
      build_series
      percentage_two_numbers(@with_diagnosis, @without_diagnosis)
    end

    def subtitle
      I18n.t('stats.series.solicitations_diagnoses.subtitle_html')
    end

    private

    def as_series(with_diagnosis, without_diagnosis)
      [
        {
          name: I18n.t('stats.without_diagnosis'),
            data: without_diagnosis
        },
        {
          name: I18n.t('stats.with_diagnosis'),
            data: with_diagnosis
        }
      ]
    end
  end
end

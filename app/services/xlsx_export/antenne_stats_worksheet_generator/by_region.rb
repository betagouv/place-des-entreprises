module XlsxExport
  module AntenneStatsWorksheetGenerator
    class ByRegion < Base
      def generate
        sheet.add_row

        add_agglomerate_headers(:region)

        Territory.deployed_regions.each do |region|
          needs = @needs.by_region(region.id)
          ratio = calculate_rate(needs.count, @needs)
          add_agglomerate_rows(needs, region.name, ratio)
        end

        finalise_agglomerate_style
      end
    end
  end
end

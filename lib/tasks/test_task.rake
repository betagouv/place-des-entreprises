task test_task: :environment do
  antenne = Antenne.find(1770)
  antenne.quarterly_reports.destroy_all
  sleep 5
  QuarterlyReports::GenerateReports.new(antenne).call
end

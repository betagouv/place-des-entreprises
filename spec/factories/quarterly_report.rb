FactoryBot.define do
  factory :quarterly_report do
    start_date { "2022-02-23" }
    end_date { "2022-02-23" }
    association :antenne
  end
end
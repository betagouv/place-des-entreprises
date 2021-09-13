FactoryBot.define do
  factory :landing do
    sequence(:slug) { |n| "landing" + Faker::Lorem.word + n.to_s }
    trait :with_subjects do
      landing_themes { build_list :landing_theme, 2, :with_subjects }
    end
  end
end

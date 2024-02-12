FactoryBot.define do
  factory :landing do
    sequence(:slug) { |n| "landing-" + Faker::Lorem.word + n.to_s }
    sequence(:title) { |n| "landing " + Faker::Lorem.word + n.to_s }
    trait :with_subjects do
      landing_themes { build_list :landing_theme, 2, :with_subjects }
    end

    trait :api do
      integration { :api }
      partner_url { 'https://www.example.com' }
    end

    trait :home do
      :with_subjects
      slug { 'accueil' }
      title { 'Accueil' }
    end
  end
end

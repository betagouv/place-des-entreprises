FactoryBot.define do
  factory :antenne do
    name { Faker::Company.unique.name }
    institution
    territorial_level { :local }
  end

  trait :national do
    territorial_level { :national }
  end

  trait :regional do
    territorial_level { :regional }
  end

  trait :local do
    territorial_level { :local }
  end

  trait :with_experts_subjects do
    after(:create) do |antenne|
      create_list(:expert_subject, 1, expert: create(:expert_with_users, antenne: antenne))
    end
  end

  trait :with_manager do
    after(:create) do |antenne|
      user = create(:user)
      user.managed_antennes.push(antenne)
    end
  end
end

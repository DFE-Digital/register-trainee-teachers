# frozen_string_literal: true

FactoryBot.define do
  factory :dqt_teacher, class: "Dqt::Teacher" do
    trn { Faker::Number.number(digits: 7) }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }

    trait :with_hesa do
      hesa_id { Faker::Number.number(digits: 13) }
    end

    trait :with_teacher_training do
      dqt_trainings { [build(:dqt_training)] }
    end
  end
end

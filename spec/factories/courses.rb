# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    provider
    sequence(:name) { |c| "Course #{c}" }
    code { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    start_date { Time.zone.today }
    level { :primary }
    age_range { AgeRange::THREE_TO_SEVEN_COURSE }
    duration_in_years { 1 }
    qualification { %i[qts pgce_with_qts pgde_with_qts pgce pgde].sample }
    course_length { %w[OneYear TwoYears].sample }
    route { TRAINING_ROUTES.keys.sample }
  end

  factory :course_with_a_subject do
    subjects { [association(:subject)] }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :allocation_subject do
    sequence(:name) { |c| "#{Faker::Educator.course_name} #{c}" }
  end
end

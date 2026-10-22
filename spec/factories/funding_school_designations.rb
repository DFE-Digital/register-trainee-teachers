# frozen_string_literal: true

FactoryBot.define do
  factory :funding_school_designation do
    school
    academic_cycle
    designation { :disadvantaged }
  end
end

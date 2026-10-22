# frozen_string_literal: true

FactoryBot.define do
  factory :relevant_degree_mapping do
    academic_cycle
    allocation_subject
    cah_level_1_code { "CAH01" }
    cah_level_2_code { "CAH01-01" }
    sequence(:hecos_code) { |n| format("1001%02d", n) }
  end
end

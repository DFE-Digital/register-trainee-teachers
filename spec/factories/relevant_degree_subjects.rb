# frozen_string_literal: true

FactoryBot.define do
  factory :relevant_degree_subject do
    academic_cycle { AcademicCycle.current || create(:academic_cycle, :current) }
    allocation_subject
    hecos_code { "100417" }
  end
end

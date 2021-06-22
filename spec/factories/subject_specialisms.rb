# frozen_string_literal: true

FactoryBot.define do
  factory :subject_specialism do
    allocation_subject

    transient do
      subject_name { nil }
    end

    sequence(:name) { |c| subject_name.presence || "#{Faker::Educator.subject.downcase} #{c}" }
  end
end

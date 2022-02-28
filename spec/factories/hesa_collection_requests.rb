# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_collection_request

  trait :import_successful do
    state { "import_successful" }
  end

  trait :import_failed do
    state { "import_failed" }
  end
end

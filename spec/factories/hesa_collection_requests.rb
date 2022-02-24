# frozen_string_literal: true

FactoryBot.define do
  factory :hesa_collection_request, class: "HesaCollectionRequest" do
    state { "importable" }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_recommendations_upload_row, class: "BulkUpdate::RecommendationsUploadRow" do
    recommendations_upload factory: %i[bulk_update_recommendations_upload]
    csv_row_number { 1 }
    trn { "12345" }
    hesa_id { "54321" }
    standards_met_at { "2023-02-16" }

    trait :missing_date do
      standards_met_at { nil }
    end

    trait :with_error do
      after(:create) do |row, _|
        create(:bulk_update_row_error, errored_on: row)
      end
    end

    trait :with_multiple_errors do
      after(:create) do |row, _|
        create_list(:bulk_update_row_error, 2, errored_on: row)
      end
    end
  end
end

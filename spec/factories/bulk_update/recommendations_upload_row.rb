# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_recommendations_upload_row, class: "BulkUpdate::RecommendationsUploadRow" do
    association :recommendations_upload, factory: :bulk_update_recommendations_upload
    csv_row_number { 1 }
    trn { "12345" }
    hesa_id { "54321" }
    standards_met_at { "2023-02-16" }
  end
end

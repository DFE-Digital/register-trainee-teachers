# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_recommendations_upload, class: "BulkUpdate::RecommendationsUpload" do
    provider

    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/bulk_update/recommendations_upload/complete.csv").open,
        filename: "test.csv",
      )
    end
  end
end

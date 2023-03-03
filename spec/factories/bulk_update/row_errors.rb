# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_row_error, class: "BulkUpdate::RowError" do
    message { "An error has occured" }
    association :errored_on, factory: :bulk_update_recommendations_upload_row
  end
end

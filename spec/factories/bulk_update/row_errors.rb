# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_row_error, class: "BulkUpdate::RowError" do
    message { "An error has occured" }
    errored_on factory: %i[bulk_update_recommendations_upload_row]
  end
end

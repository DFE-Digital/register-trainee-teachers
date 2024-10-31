# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_trainee_upload_row, class: "BulkUpdate::TraineeUploadRow" do
    bulk_update_trainee_upload { nil }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_trainee_upload, class: "BulkUpdate::TraineeUpload" do
    provider
    status { "pending" }
    number_of_trainees { 10 }
    file_name { "test.csv" }
    file { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/complete.csv").read }
  end
end


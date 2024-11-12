# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_trainee_upload, class: "BulkUpdate::TraineeUpload" do
    provider
    status { "pending" }
    number_of_trainees { 5 }
    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv").open,
        filename: "five_trainees.csv",
      )
    end

    trait :with_rows do
      after(:create) do |upload|
        CSV.parse(upload.file.download, headers: true).map.with_index do |row, index|
          create(
            :bulk_update_trainee_upload_row,
            bulk_update_trainee_upload: upload,
            data: row.to_h,
            row_number: index + 1,
          )
        end
      end
    end
  end
end

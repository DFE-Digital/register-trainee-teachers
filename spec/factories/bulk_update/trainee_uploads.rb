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
            trainee_upload: upload,
            data: row.to_h,
            row_number: index + 1,
          )
        end
      end
    end

    trait :failed do
      status { "failed" }

      file_name { "five_trainees_with_two_errors" }
      file { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").read }

      after(:build) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.file, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              error_type: :duplicate,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          end
        end
      end
    end

    trait :failed_with_validation_errors do
      status { "failed" }

      file_name { "five_trainees_with_two_errors" }
      file { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").read }

      after(:build) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.file, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          end
        end
      end
    end

    trait :failed_with_duplicate_errors do
      status { "failed" }

      file_name { "five_trainees_with_two_errors" }
      file { Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").read }

      after(:build) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.file, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              error_type: :duplicate,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
              row_number: index + 1,
            )
          end
        end
      end
    end
  end
end

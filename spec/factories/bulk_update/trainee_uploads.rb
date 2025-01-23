# frozen_string_literal: true

UPLOAD_ERROR_MESSAGES = [
  "Invalid email address",
  "Invalid date of birth",
  "Invalid degree grade",
  "Missing placement data",
  "Missing degree data",
].freeze

FactoryBot.define do
  factory :bulk_update_trainee_upload, class: "BulkUpdate::TraineeUpload" do
    provider

    after(:build) do |upload|
      upload.file.attach(
        io: Rails.root.join(
          "spec/fixtures/files/bulk_update/trainee_uploads/five_trainees.csv",
        ).open,
        filename: "five_trainees.csv",
      )
    end

    trait(:with_errors) do
      after(:build) do |bulk_update_trainee_upload|
        bulk_update_trainee_upload.attach(
          io: Rails.root.join("spec/fixtures/files/bulk_update/trainee_uploads/five_trainees_with_two_errors.csv").open,
          filename: "five_trainees_with_two_errors.csv",
        )
      end
    end

    trait :with_rows do
      validated

      after(:create) do |upload|
        CSV.parse(upload.download, headers: true).each do |row|
          create(
            :bulk_update_trainee_upload_row,
            trainee_upload: upload,
            data: row.to_h,
          )
        end
      end
    end

    trait :uploaded do
      status { "uploaded" }
    end

    trait :pending do
      status { "pending" }
    end

    trait :validated do
      status { "validated" }
    end

    trait :in_progress do
      status { "in_progress" }
      submitted_by { association(:user) }
      submitted_at { Time.current }
    end

    trait :succeeded do
      status { "succeeded" }
      submitted_by { association(:user) }
      submitted_at { Time.current }

      with_rows
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :failed do
      status { "failed" }
      submitted_by { association(:user) }
      submitted_at { Time.current }

      after(:create) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.download, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              error_type: :duplicate,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          end
        end
      end
    end

    trait :failed_without_errors do
      status { "failed" }
      submitted_by { association(:user) }
      submitted_at { Time.current }
    end

    trait :failed_with_validation_errors do
      status { "failed" }

      after(:create) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.download, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          end
        end
      end
    end

    trait :failed_with_duplicate_errors do
      status { "failed" }

      after(:create) do |bulk_update_trainee_upload|
        CSV.parse(bulk_update_trainee_upload.download, headers: true).each_with_index do |row, index|
          if index < 3
            create(
              :bulk_update_trainee_upload_row,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          else
            create(
              :bulk_update_trainee_upload_row,
              :with_errors,
              error_type: :duplicate,
              trainee_upload: bulk_update_trainee_upload,
              data: row.to_h,
            )
          end
        end
      end
    end
  end
end

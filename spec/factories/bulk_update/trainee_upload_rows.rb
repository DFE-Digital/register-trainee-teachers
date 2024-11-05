# frozen_string_literal: true

FactoryBot.define do
  factory :bulk_update_trainee_upload_row, class: "BulkUpdate::TraineeUploadRow" do
    trainee_upload factory: %i[bulk_update_trainee_upload]

    sequence(:row_number) { |n| n }

    data { {}.to_json }

    transient do
      error_type { "validation" }
    end

    trait :with_errors do
      after(:build) do |bulk_update_trainee_upload_row, evaluator|
        create(
          :bulk_update_row_error,
          error_type: evaluator.error_type,
          errored_on: bulk_update_trainee_upload_row,
          message: "An error has occured",
        )
      end
    end
  end
end

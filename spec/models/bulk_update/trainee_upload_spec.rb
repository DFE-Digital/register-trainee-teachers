# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUpload do
  it { is_expected.to belong_to(:provider) }
  it { is_expected.to have_many(:trainee_upload_rows).dependent(:destroy) }

  it do
    expect(subject).to define_enum_for(:status).with_values(
      pending: "pending",
      validated: "validated",
      in_progress: "in_progress",
      succeeded: "succeeded",
      failed: "failed",
      cancelled: "cancelled",
    ).backed_by_column_of_type(:string)
  end

  describe "#total_rows_with_errors" do
    subject(:trainee_upload) { create(:bulk_update_trainee_upload) }

    let!(:rows_with_validation_errors) do
      create_list(
        :bulk_update_trainee_upload_row,
        2,
        :with_multiple_errors,
        trainee_upload: trainee_upload,
        error_type: :validation,
      )
    end
    let!(:rows_with_duplicate_errors) do
      create_list(
        :bulk_update_trainee_upload_row,
        2,
        :with_errors,
        trainee_upload: trainee_upload,
        error_type: :duplicate,
      )
    end
    let!(:rows_without_errors) do
      create_list(:bulk_update_trainee_upload_row, 2, trainee_upload:)
    end

    it "returns the correct number of rows with errors" do
      expect(trainee_upload.total_rows_with_errors).to eq(4)
    end
  end
end

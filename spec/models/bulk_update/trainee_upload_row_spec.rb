# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadRow do
  it { is_expected.to belong_to(:trainee_upload) }
  it { is_expected.to have_many(:row_errors).dependent(:destroy) }

  describe "#without_errors" do
    let!(:rows_with_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_errors) }
    let!(:rows_without_errors) { create_list(:bulk_update_trainee_upload_row, 2) }

    it "returns only the trainee upload rows that don't have errors" do
      expect(described_class.without_errors).to match_array(rows_without_errors)
    end
  end

  describe ".with_errors" do
    let!(:rows_with_validation_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_multiple_errors, error_type: :validation) }
    let!(:rows_with_duplicate_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_errors, error_type: :duplicate) }
    let!(:rows_without_errors) { create_list(:bulk_update_trainee_upload_row, 2) }

    it "returns all distinct error rows" do
      expect(described_class.with_errors).to match_array(rows_with_validation_errors + rows_with_duplicate_errors)
    end
  end

  describe ".with_validation_errors" do
    let!(:rows_with_validation_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_multiple_errors, error_type: :validation) }
    let!(:rows_with_duplicate_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_errors, error_type: :duplicate) }
    let!(:rows_without_errors) { create_list(:bulk_update_trainee_upload_row, 2) }

    it "returns only distinct validation error rows" do
      expect(described_class.with_validation_errors).to match_array(rows_with_validation_errors)
    end
  end

  describe ".with_duplicate_errors" do
    let!(:rows_with_validation_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_multiple_errors, error_type: :validation) }
    let!(:rows_with_duplicate_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_errors, error_type: :duplicate) }
    let!(:rows_without_errors) { create_list(:bulk_update_trainee_upload_row, 2) }

    it "returns only distinct duplicate error rows" do
      expect(described_class.with_duplicate_errors).to match_array(rows_with_duplicate_errors)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::TraineeUploadRow do
  it { is_expected.to belong_to(:trainee_upload) }
  it { is_expected.to have_many(:row_errors) }

  describe "#without_errors" do
    let!(:rows_with_errors) { create_list(:bulk_update_trainee_upload_row, 2, :with_errors) }
    let!(:rows_without_errors) { create_list(:bulk_update_trainee_upload_row, 2) }

    it "returns only the trainee upload rows that don't have errors" do
      expect(described_class.without_errors).to eq(rows_without_errors)
    end
  end
end

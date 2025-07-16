# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolDataDownload do
  describe "validations" do
    it "requires started_at" do
      download = build(:school_data_download, started_at: nil)
      expect(download).not_to be_valid
      expect(download.errors[:started_at]).to include("can't be blank")
    end

    it "requires file_count when completed" do
      download = build(:school_data_download, status: :completed, file_count: nil)
      expect(download).not_to be_valid
      expect(download.errors[:file_count]).to include("can't be blank")
    end

    it "does not require file_count when not completed" do
      download = build(:school_data_download, status: :pending, file_count: nil)
      expect(download).to be_valid
    end
  end

  describe "status enum" do
    it "provides status enum helpers" do
      download = build(:school_data_download, status: :pending)

      expect(download).to be_pending
      expect(download).not_to be_completed

      download.status = :completed
      expect(download).to be_completed
      expect(download).not_to be_pending
    end

    it "can transition to failed with error message" do
      download = create(:school_data_download, status: :downloading)

      download.update!(status: :failed, error_message: "Network error")
      expect(download).to be_failed
      expect(download.error_message).to eq("Network error")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolDataDownload do
  describe "enums" do
    it "defines status enum with correct values" do
      expect(described_class.statuses).to eq({
        "pending" => 0,
        "downloading" => 1,
        "extracting" => 2,
        "processing" => 3,
        "completed" => 4,
        "failed" => 5,
      })
    end

    it "provides status enum helpers" do
      download = build(:school_data_download, status: :pending)

      expect(download).to be_pending
      expect(download).not_to be_completed

      download.status = :completed
      expect(download).to be_completed
      expect(download).not_to be_pending
    end
  end

  describe "validations" do
    it "requires started_at" do
      download = build(:school_data_download, started_at: nil)
      expect(download).not_to be_valid
      expect(download.errors[:started_at]).to include("can't be blank")
    end

    context "when status is completed" do
      it "requires file_count" do
        download = build(:school_data_download, status: :completed, file_count: nil)
        expect(download).not_to be_valid
        expect(download.errors[:file_count]).to include("can't be blank")
      end

      it "is valid with required fields" do
        download = build(:school_data_download,
                         status: :completed,
                         file_count: 2)
        expect(download).to be_valid
      end
    end

    context "when status is not completed" do
      it "does not require file_count" do
        download = build(:school_data_download, status: :pending, file_count: nil)
        expect(download).to be_valid
      end
    end
  end

  describe "scopes" do
    let!(:old_download) { create(:school_data_download, started_at: 2.months.ago) }
    let!(:recent_download) { create(:school_data_download, started_at: 2.weeks.ago) }
    let!(:failed_download) { create(:school_data_download, started_at: 1.week.ago, status: :failed) }
    let!(:completed_download) { create(:school_data_download, :completed, started_at: 1.week.ago) }

    describe ".recent" do
      it "returns downloads from the last month" do
        expect(described_class.recent).to include(recent_download, failed_download, completed_download)
        expect(described_class.recent).not_to include(old_download)
      end
    end

    describe ".successful" do
      it "returns only completed downloads" do
        expect(described_class.successful).to contain_exactly(completed_download)
      end
    end
  end

  describe "#duration" do
    context "when both started_at and completed_at are present" do
      it "returns the difference in seconds" do
        started_at = Time.zone.parse("2023-01-01 10:00:00")
        completed_at = Time.zone.parse("2023-01-01 10:05:30")

        download = build(:school_data_download,
                         started_at:,
                         completed_at:)

        expect(download.duration).to eq(330.0) # 5 minutes 30 seconds
      end
    end

    context "when completed_at is missing" do
      it "returns nil" do
        download = build(:school_data_download,
                         started_at: 1.hour.ago,
                         completed_at: nil)

        expect(download.duration).to be_nil
      end
    end

    context "when started_at is missing" do
      it "returns nil" do
        download = build(:school_data_download,
                         started_at: nil,
                         completed_at: Time.current)

        expect(download.duration).to be_nil
      end
    end

    context "when both timestamps are missing" do
      it "returns nil" do
        download = build(:school_data_download,
                         started_at: nil,
                         completed_at: nil)

        expect(download.duration).to be_nil
      end
    end
  end

  describe "database constraints" do
    it "has default values for certain fields" do
      download = described_class.create!(started_at: Time.current)

      expect(download.status).to eq("pending")
      expect(download.schools_created).to eq(0)
      expect(download.schools_updated).to eq(0)
    end

    it "allows null values for optional fields" do
      download = described_class.create!(started_at: Time.current)

      expect(download.completed_at).to be_nil
      expect(download.error_message).to be_nil
      expect(download.file_count).to be_nil
    end
  end

  describe "status transitions" do
    it "can transition through all statuses" do
      download = create(:school_data_download, status: :pending)

      download.update!(status: :downloading)
      expect(download).to be_downloading

      download.update!(status: :extracting)
      expect(download).to be_extracting

      download.update!(status: :processing)
      expect(download).to be_processing

      download.update!(status: :completed,
                       completed_at: Time.current,
                       file_count: 2)
      expect(download).to be_completed
    end

    it "can transition to failed from any status" do
      download = create(:school_data_download, status: :downloading)

      download.update!(status: :failed,
                       error_message: "Network error",
                       completed_at: Time.current)
      expect(download).to be_failed
      expect(download.error_message).to eq("Network error")
    end
  end
end

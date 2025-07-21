# frozen_string_literal: true

# == Schema Information
#
# Table name: school_data_downloads
#
#  id                    :bigint           not null, primary key
#  completed_at          :datetime
#  error_message         :text
#  lead_partners_updated :integer
#  rows_filtered         :integer
#  rows_processed        :integer
#  schools_created       :integer
#  schools_updated       :integer
#  source                :string
#  started_at            :datetime
#  status                :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class SchoolDataDownload < ApplicationRecord
  enum :status, {
    pending: "pending",
    downloading: "downloading",
    filtering_complete: "filtering_complete",
    processing: "processing",
    completed: "completed",
    failed: "failed",
  }, prefix: true

  validates :status, presence: true
  validates :started_at, presence: true
  validates :source, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: :completed) }
  scope :failed, -> { where(status: :failed) }

  def duration
    return nil unless started_at && completed_at

    completed_at - started_at
  end

  def success?
    status == "completed"
  end

  def in_progress?
    %w[pending downloading filtering_complete processing].include?(status)
  end
end

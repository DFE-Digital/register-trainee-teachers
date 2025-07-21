# frozen_string_literal: true

# == Schema Information
#
# Table name: school_data_downloads
#
#  id                    :bigint           not null, primary key
#  completed_at          :datetime
#  lead_partners_updated :integer
#  schools_created       :integer
#  schools_updated       :integer
#  started_at            :datetime         not null
#  status                :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_school_data_downloads_on_started_at  (started_at)
#  index_school_data_downloads_on_status      (status)
#
class SchoolDataDownload < ApplicationRecord
  enum :status, {
    running: "running",
    completed: "completed",
    failed: "failed",
  }, prefix: true

  validates :status, presence: true
  validates :started_at, presence: true

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
    status == "running"
  end
end

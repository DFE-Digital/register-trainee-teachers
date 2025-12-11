# frozen_string_literal: true

# == Schema Information
#
# Table name: school_data_downloads
#
#  id                        :bigint           not null, primary key
#  completed_at              :datetime
#  schools_created           :integer
#  schools_deleted           :integer
#  schools_updated           :integer
#  started_at                :datetime         not null
#  status                    :string           not null
#  training_partners_updated :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
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
end

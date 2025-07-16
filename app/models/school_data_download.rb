# frozen_string_literal: true

# == Schema Information
#
# Table name: school_data_downloads
#
#  id              :bigint           not null, primary key
#  completed_at    :datetime
#  error_message   :text
#  file_count      :integer
#  schools_created :integer          default(0)
#  schools_updated :integer          default(0)
#  started_at      :datetime         not null
#  status          :integer          default("pending"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_school_data_downloads_on_started_at  (started_at)
#  index_school_data_downloads_on_status      (status)
#
class SchoolDataDownload < ApplicationRecord
  enum :status, {
    pending: 0,
    downloading: 1,
    extracting: 2,
    processing: 3,
    completed: 4,
    failed: 5,
  }

  validates :started_at, presence: true
  validates :file_count, presence: true, if: :completed?
end

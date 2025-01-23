# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_trainee_uploads
#
#  id                 :bigint           not null, primary key
#  number_of_trainees :integer          default(0), not null
#  status             :string           default("pending")
#  submitted_at       :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  provider_id        :bigint           not null
#  submitted_by_id    :bigint
#
# Indexes
#
#  index_bulk_update_trainee_uploads_on_provider_id      (provider_id)
#  index_bulk_update_trainee_uploads_on_status           (status)
#  index_bulk_update_trainee_uploads_on_submitted_by_id  (submitted_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (submitted_by_id => users.id)
#

class BulkUpdate::TraineeUpload < ApplicationRecord
  enum :status, {
    pending: "pending",
    validated: "validated",
    in_progress: "in_progress",
    succeeded: "succeeded",
    cancelled: "cancelled",
    failed: "failed",
  } do
    event :process do
      transition %i[pending] => :validated
    end

    event :submit do
      before do
        self.submitted_by = Current.user
        self.submitted_at = Time.current
      end

      transition %i[validated] => :in_progress
    end

    event :succeed do
      transition %i[in_progress] => :succeeded
    end

    event :cancel do
      transition %i[validated failed] => :cancelled
    end

    event :fail do
      transition %i[pending validated in_progress] => :failed
    end
  end

  belongs_to :provider
  belongs_to :submitted_by, class_name: "User", optional: true

  has_many :trainee_upload_rows,
           class_name: "BulkUpdate::TraineeUploadRow",
           foreign_key: :bulk_update_trainee_upload_id,
           inverse_of: :trainee_upload,
           dependent: :destroy

  has_many :row_errors, through: :trainee_upload_rows
  has_one_attached :file

  delegate :filename, :download, :attach, to: :file

  scope :current_academic_cycle, lambda {
    where(created_at: AcademicCycle.current.start_date..AcademicCycle.current.end_date)
  }

  def total_rows_with_errors
    trainee_upload_rows.with_errors.size
  end
end

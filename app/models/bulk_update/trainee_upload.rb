# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_trainee_uploads
#
#  id                 :bigint           not null, primary key
#  number_of_trainees :integer
#  status             :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  provider_id        :bigint           not null
#
# Indexes
#
#  index_bulk_update_trainee_uploads_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#

class BulkUpdate::TraineeUpload < ApplicationRecord
  belongs_to :provider
  has_many :bulk_update_trainee_upload_rows,
           class_name: "BulkUpdate::TraineeUploadRow",
           foreign_key: :bulk_update_trainee_upload_id,
           inverse_of: :bulk_update_trainee_upload,
           dependent: :destroy

  has_one_attached :file

  enum :status, {
    pending: "pending",
    validated: "validated",
    in_progress: "in_progress",
    succeeded: "succeeded",
    failed: "failed",
  }
end

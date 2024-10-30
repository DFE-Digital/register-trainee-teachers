# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_trainee_upload_rows
#
#  id                            :bigint           not null, primary key
#  data                          :jsonb            not null
#  row_number                    :integer          not null
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  bulk_update_trainee_upload_id :bigint           not null
#
# Indexes
#
#  idx_on_bulk_update_trainee_upload_id_21ca71cc91                 (bulk_update_trainee_upload_id)
#  index_bulk_update_trainee_upload_rows_on_upload_and_row_number  (bulk_update_trainee_upload_id,row_number) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (bulk_update_trainee_upload_id => bulk_update_trainee_uploads.id)
#
class BulkUpdate::TraineeUploadRow < ApplicationRecord
  belongs_to :trainee_upload,
             class_name: "BulkUpdate::TraineeUpload",
             foreign_key: :bulk_update_trainee_upload_id,
             inverse_of: :trainee_upload_rows

  has_many :row_errors, as: :errored_on, class_name: "BulkUpdate::RowError", dependent: :destroy

  validates :row_number, presence: true
  validates :data, presence: true
end

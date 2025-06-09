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

  scope :without_errors, -> { left_joins(:row_errors).where(row_errors: { errored_on_id: nil }) }
  scope :with_errors, lambda {
    distinct("trainee_upload_rows.id").joins(:row_errors)
  }
  scope :with_validation_errors, lambda {
    with_errors.merge(BulkUpdate::RowError.validation)
  }
  scope :with_duplicate_errors, lambda {
    with_errors.merge(BulkUpdate::RowError.duplicate)
  }

  before_save :remove_leading_apostrophes

private

  def remove_leading_apostrophes
    data.transform_values! do |value|
      value.is_a?(String) && value.start_with?("'") ? value[1..] : value
    end
  end
end

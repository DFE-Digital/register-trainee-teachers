# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_recommendations_uploads
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint           not null
#
# Indexes
#
#  index_bulk_update_recommendations_uploads_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
class BulkUpdate::RecommendationsUpload < ApplicationRecord
  belongs_to :provider
  has_one_attached :file
  has_many :recommendations_upload_rows,
           class_name: "BulkUpdate::RecommendationsUploadRow",
           foreign_key: :bulk_update_recommendations_upload_id,
           dependent: :destroy,
           inverse_of: :recommendations_upload

  alias rows recommendations_upload_rows

  def awardable_rows
    rows.includes(:trainee).where.not(standards_met_at: nil).where.missing(:row_errors)
  end

  def empty_row_ids
    rows.select(&:all_parameters_blank?).pluck(:id)
  end

  def missing_date_rows
    rows.where(standards_met_at: nil).where.missing(:row_errors).where.not(id: empty_row_ids)
  end

  def error_rows
    rows.where.associated(:row_errors).distinct
  end
end

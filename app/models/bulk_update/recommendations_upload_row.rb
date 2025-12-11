# frozen_string_literal: true

# == Schema Information
#
# Table name: bulk_update_recommendations_upload_rows
#
#  id                                    :bigint           not null, primary key
#  age_range                             :string
#  csv_row_number                        :integer
#  first_names                           :string
#  last_names                            :string
#  phase                                 :string
#  qts_or_eyts                           :string
#  route                                 :string
#  standards_met_at                      :date
#  subject                               :string
#  training_partner                      :string
#  trn                                   :string
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  bulk_update_recommendations_upload_id :bigint           not null
#  hesa_id                               :string
#  matched_trainee_id                    :bigint
#  provider_trainee_id                   :string
#
# Indexes
#
#  idx_bu_recommendations_upload_rows_on_matched_trainee_id  (matched_trainee_id)
#  idx_bu_ru_rows_on_bu_recommendations_upload_id            (bulk_update_recommendations_upload_id)
#
# Foreign Keys
#
#  fk_rails_...  (bulk_update_recommendations_upload_id => bulk_update_recommendations_uploads.id)
#  fk_rails_...  (matched_trainee_id => trainees.id)
#
class BulkUpdate::RecommendationsUploadRow < ApplicationRecord
  belongs_to :recommendations_upload,
             class_name: "BulkUpdate::RecommendationsUpload",
             foreign_key: :bulk_update_recommendations_upload_id,
             inverse_of: :recommendations_upload_rows

  belongs_to :trainee,
             foreign_key: :matched_trainee_id,
             inverse_of: :recommendations_upload_rows,
             optional: true

  has_many :row_errors, as: :errored_on, class_name: "BulkUpdate::RowError"

  def row_error_messages
    row_errors.map(&:message).join("\n")
  end

  def all_parameters_blank?
    %w[first_names last_names lead_partner phase qts_or_eyts route standards_met_at subject trn hesa_id].all? { |attr| self[attr].blank? }
  end

  def qts?
    trainee&.award_type == "QTS"
  end

  def eyts?
    trainee&.award_type == "EYTS"
  end
end

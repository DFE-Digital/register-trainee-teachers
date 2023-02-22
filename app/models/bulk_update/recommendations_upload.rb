# == Schema Information
#
# Table name: bulk_update_recommendations_uploads
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_bulk_update_recommendations_uploads_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class BulkUpdate::RecommendationsUpload < ApplicationRecord
  belongs_to :user
  has_one_attached :file
  has_many :bulk_update_recommended_trainees, class_name: "BulkUpdate::RecommendedTrainee", dependent: :destroy

  alias trainees bulk_update_recommended_trainees
end

# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_uploads_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Upload < ApplicationRecord
  VALID_CONTENT_TYPES = ["text/csv", "application/xml", "application/zip"].freeze
  MAX_FILE_SIZE = 50.megabytes

  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name, using: %i[tsearch trigram]

  belongs_to :user
  has_one_attached :file

  validates :file, presence: true, file: { content_type: VALID_CONTENT_TYPES, size_limit: MAX_FILE_SIZE }
  validates :name, presence: true
end

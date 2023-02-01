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
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name, using: %i[tsearch trigram]

  belongs_to :user
  has_one_attached :file

  validates :file, presence: true
  validates :name, presence: true
end

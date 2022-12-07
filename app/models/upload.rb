# frozen_string_literal: true

class Upload < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_by_name, against: :name, using: %i[tsearch trigram]

  belongs_to :user
  has_one_attached :file

  validates :file, presence: true
  validates :name, presence: true
end

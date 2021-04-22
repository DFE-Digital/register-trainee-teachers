# frozen_string_literal: true

class School < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: %i[urn name town postcode], using: { tsearch: { prefix: true } }

  scope :open, -> { where(close_date: nil) }
  scope :lead_only, -> { where(lead_school: true) }

  validates :urn, presence: true, uniqueness: true
  validates :name, presence: true
  validates :lead_school, inclusion: { in: [true, false] }

  def urn_and_location
    [urn, town, postcode].join(", ")
  end
end

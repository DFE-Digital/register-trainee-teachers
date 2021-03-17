# frozen_string_literal: true

class Course < ApplicationRecord
  belongs_to :provider

  validates :code, presence: true, uniqueness: { scope: :provider_id }
  validates :name, presence: true
end

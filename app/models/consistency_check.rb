# frozen_string_literal: true

class ConsistencyCheck < ApplicationRecord
  validates :trainee, presence: true
  belongs_to :trainee
end

# frozen_string_literal: true

class ConsistencyCheck < ApplicationRecord
  validates :trainee_id, presence: true
end

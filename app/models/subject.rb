# frozen_string_literal: true

class Subject < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true
end

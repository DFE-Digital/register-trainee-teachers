# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider

  validates :application, presence: true
end

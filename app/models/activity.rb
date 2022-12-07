# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :user

  validates :controller_name, :action_name, presence: true

  def self.track(user:, controller_name:, action_name:, metadata: {})
    create!(
      user:,
      controller_name:,
      action_name:,
      metadata:,
    )
  end
end

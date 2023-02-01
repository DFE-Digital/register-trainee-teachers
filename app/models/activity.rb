# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  id              :bigint           not null, primary key
#  action_name     :string
#  controller_name :string
#  metadata        :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_activities_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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

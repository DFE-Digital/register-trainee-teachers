# frozen_string_literal: true

class SessionStoreTruncateJob < ApplicationJob
  queue_as :default

  def perform
    # Copying from: rake db:sessions:trim
    cutoff_period = (ENV["SESSION_DAYS_TRIM_THRESHOLD"] || 30).to_i.days.ago
    ActiveRecord::SessionStore::Session.where("updated_at < ?", cutoff_period).delete_all
  end
end

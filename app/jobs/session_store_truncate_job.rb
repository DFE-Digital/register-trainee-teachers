# frozen_string_literal: true

class SessionStoreTruncateJob < ApplicationJob
  queue_as :default

  def perform
    # Copying from: rake db:sessions:trim
    cutoff_period = Settings.session_store.expire_after_days.days.ago
    ActiveRecord::SessionStore::Session.where("updated_at < ?", cutoff_period).delete_all
  end
end

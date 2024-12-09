# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :microsoft
end

# frozen_string_literal: true

require Rails.root.join("config/environments/production")

Rails.application.configure do
  # Store uploaded files on the local file system or Azure storage if a key is set (see config/storage.yml for options).
  config.active_storage.service = Settings.azure&.storage&.temp_data_access_key.present? ? :microsoft : :local
end

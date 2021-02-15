# frozen_string_literal: true

Kaminari.configure do |config|
  config.default_per_page = Settings.pagination.records_per_page
end

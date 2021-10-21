# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
SANITIZED_REQUEST_PARAMS = %i[
  address_line_one
  address_line_two
  date_of_birth
  email
  first_name
  first_names
  international_address
  last_name
  middle_names
  password
  postcode
  region
  token
  town_city
].freeze

Rails.application.config.filter_parameters += SANITIZED_REQUEST_PARAMS

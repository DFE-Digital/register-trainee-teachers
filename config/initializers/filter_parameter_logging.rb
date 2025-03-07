# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure parameters to be filtered from the log file. Use this to limit dissemination of
# sensitive information. See the ActiveSupport::ParameterFilter documentation for supported
# notations and behaviors.
#
Rails.application.config.filter_parameters += [
  # Rails defaults
  :passw,
  :secret,
  :token,
  :_key,
  :crypt,
  :salt,
  :certificate,
  :otp,
  :ssn,
  # App specific
  :address_line_one,
  :address_line_two,
  :date_of_birth,
  :email,
  :first_name,
  :first_names,
  :international_address,
  :last_name,
  :middle_names,
  :password,
  :postcode,
  :region,
  :town_city,
  :trn,
  :audited_changes,
]

# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "rspec/core"
require "config"
require "httparty"

Config.load_and_set_settings(Config.setting_files("config", ENV["RAILS_ENV"]))

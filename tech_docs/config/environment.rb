# frozen_string_literal: true

lib = File.expand_path("../lib", __dir__)
app = File.expand_path("../../app", __dir__)

$LOAD_PATH.unshift(lib, app)

Config.load_and_set_settings(Config.setting_files("../config", ENV["RAILS_ENV"]))

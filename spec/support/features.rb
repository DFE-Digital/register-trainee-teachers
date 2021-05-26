# frozen_string_literal: true

feature_support_files = Dir["#{__dir__}/features/*"]
feature_support_files.each { |file| require file }

require_relative "dfe_sign_in_user_helper"

RSpec.configure do |config|
  # Helper method to normalise the feature metadata key name, eg :feature_trainees -> :trainees
  normalise_feature_name = ->(feature) { feature.to_s.delete_prefix("feature_").to_sym }

  settings_has_key = lambda do |feature_name|
    segments = feature_name.to_s.split(".")
    final_key = segments.last
    segments[0..-2].reduce(Settings.features) { |settings, segment| settings[segment] }.key? final_key.to_sym
  end

  set_feature = lambda do |feature_name, value|
    segments = feature_name.to_s.split(".")
    final_key = segments.last
    segments[0..-2].reduce(Settings.features) { |settings, segment| settings[segment] }[final_key.to_sym] = value
  end

  feature_support_files.map { |path| File.basename(path, ".rb") }.each do |file_name|
    config.include "Features::#{file_name.camelize}".constantize, type: :feature
  end

  config.include DfESignInUserHelper, type: :feature

  config.around :each do |example|
    original_features = {}
    features = example.metadata.keys.grep(/^feature_.*/)

    features.each do |metadata_key|
      feature = normalise_feature_name.call(metadata_key)
      if settings_has_key.call(feature)
        original_features[feature] = FeatureService.enabled?(feature)
      end

      set_feature.call(feature, example.metadata[metadata_key])
    end

    example.run

    features.each do |metadata_key|
      feature = normalise_feature_name.call(metadata_key)
      set_feature.call(feature, original_features[feature])
    end
  end
end

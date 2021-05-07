# frozen_string_literal: true

require_relative "features/authentication_steps"
require_relative "features/trainee_steps"
require_relative "features/dttp_steps"
require_relative "features/common_steps"
require_relative "features/page_helpers"
require_relative "features/diversity_steps"
require_relative "features/confirmation_steps"
require_relative "features/js_helpers"
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

  config.include Features::AuthenticationSteps, type: :feature
  config.include Features::TraineeSteps, type: :feature
  config.include Features::DttpSteps, type: :feature
  config.include Features::CommonSteps, type: :feature
  config.include Features::PageHelpers, type: :feature
  config.include Features::DiversitySteps, type: :feature
  config.include Features::ConfirmationSteps, type: :feature
  config.include Features::JsHelpers, type: :feature
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

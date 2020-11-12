require_relative "features/authentication_steps"
require_relative "features/trainee_steps"

RSpec.configure do |config|
  # Store original feature flag values before the examples run
  original_features = {}

  # Helper method to normalise the feature metadata key name, eg :feature_trainees -> :trainees
  normalise_feature_name = ->(feature) { feature.to_s.delete_prefix("feature_").to_sym }

  config.include Features::AuthenticationSteps, type: :feature
  config.include Features::TraineeSteps, type: :feature

  config.around :each do |example|
    example.metadata.keys.grep(/^feature_.*/) do |metadata_key|
      feature = normalise_feature_name.call(metadata_key)

      if Settings.features.key?(feature)
        original_features[feature] = Settings.features[feature]
      end

      Settings.features[feature] = example.metadata[metadata_key]
    end

    example.run
  end

  config.after :each do |example|
    features = example.metadata.keys.grep(/^feature_.*/)

    features.each do |metadata_key|
      feature = normalise_feature_name.call(metadata_key)

      if original_features.key?(feature)
        Settings.features[feature] = original_features[feature]
      end
    end
  end
end

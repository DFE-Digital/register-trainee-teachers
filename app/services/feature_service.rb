# frozen_string_literal: true

module FeatureService
  class << self
    def enabled?(feature_name)
      return false if Settings.features.blank?

      segments = feature_name.to_s.split(".")
      segments.reduce(Settings.features) { |config, segment| config[segment] }
    end

    # i.e full data set is loaded locally and you need to log in as an admin (bypassing the persona page)
    def performance_testing?
      Rails.env.development? && ENV.fetch("PERFORMANCE_TESTING", false)
    end
  end
end

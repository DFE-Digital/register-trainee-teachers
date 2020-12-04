# frozen_string_literal: true

require "rails_helper"

describe "Settings" do
  settings = YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access
  expected_value_test = "expected_value_test"

  shared_examples expected_value_test do |key, source, expected_value|
    describe ".#{key}" do
      subject do
        source[key]
      end

      it "#{key} has a default value" do
        expect(subject).to eq(expected_value)
      end
    end
  end

  include_examples expected_value_test, :port, settings, 5000
  include_examples expected_value_test, :base_url, settings, "https://localhost:5000"

  describe ".features" do
    features = settings[:features]

    include_examples expected_value_test, :use_ssl, features, true
    include_examples expected_value_test, :use_dfe_sign_in, features, true
    include_examples expected_value_test, :home_text, features, false
    include_examples expected_value_test, :allow_user_creation, features, false
  end

  describe ".dfe_sign_in" do
    dfe_sign_in = settings[:dfe_sign_in]

    include_examples expected_value_test, :identifier, dfe_sign_in, "rtt"
    include_examples expected_value_test, :issuer, dfe_sign_in, "https://test-oidc.signin.education.gov.uk"
    include_examples expected_value_test, :profile, dfe_sign_in, "https://test-profile.signin.education.gov.uk"
    include_examples expected_value_test, :secret, dfe_sign_in, "secret required value"
  end
end

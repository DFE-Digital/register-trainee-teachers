# frozen_string_literal: true

require "rails_helper"

def settings
  YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access
end

def expected_value_test
  "expected_value_test"
end

describe "Settings" do
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

  it_behaves_like expected_value_test, :port, settings, 5000
  it_behaves_like expected_value_test, :base_url, settings, "https://localhost:5000"

  describe ".features" do
    it_behaves_like expected_value_test, :use_ssl, settings[:features], true
    it_behaves_like expected_value_test, :sign_in_method, settings[:features], "dfe-sign-in"
    it_behaves_like expected_value_test, :home_text, settings[:features], false
  end

  describe ".dfe_sign_in" do
    it_behaves_like expected_value_test, :identifier, settings[:dfe_sign_in], "rtt"
    it_behaves_like expected_value_test, :issuer, settings[:dfe_sign_in], "https://test-oidc.signin.education.gov.uk"
    it_behaves_like expected_value_test, :profile, settings[:dfe_sign_in], "https://test-profile.signin.education.gov.uk"
    it_behaves_like expected_value_test, :secret, settings[:dfe_sign_in], "secret required value"
  end

  describe ".jobs" do
    it_behaves_like expected_value_test, :poll_delay_hours, settings[:jobs], 1
    it_behaves_like expected_value_test, :max_poll_duration_days, settings[:jobs], 4
  end
end

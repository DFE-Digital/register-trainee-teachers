# frozen_string_literal: true

require "rails_helper"

describe "Settings" do
  settings = YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access
  describe ".features" do
    subject do
      settings[:features]
    end

    it "default for use ssl returns true" do
      expect(subject[:use_ssl]).to eq(true)
    end

    it "default for use dfe sign in returns true" do
      expect(subject[:use_dfe_sign_in]).to eq(true)
    end

    it "default for home text returns false" do
      expect(subject[:home_text]).to eq(false)
    end

    it "default for allow user creation returns false" do
      expect(subject[:allow_user_creation]).to eq(false)
    end
  end

  describe ".port" do
    subject do
      settings[:port]
    end

    it "default for port is 5000" do
      expect(subject).to eq(5000)
    end
  end

  required_value = "required_value"
  shared_examples required_value do |key, value|
    describe ".#{key}" do
      subject do
        value
      end

      it "#{key} is a #{required_value}" do
        expect(subject).to eq("#{key} #{required_value.humanize(capitalize: false)}")
      end
    end
  end

  describe ".dfe_sign_in" do
    settings[:dfe_sign_in].keys.each do |key|
      include_examples required_value, key, settings[:dfe_sign_in][key]
    end
  end

  describe ".base_url" do
    include_examples required_value, :base_url, settings[:base_url]
  end
end

# frozen_string_literal: true

require "rails_helper"

describe "Settings" do
  let(:settings) { YAML.load_file(Rails.root.join("config/settings.yml")).with_indifferent_access }
  describe ".features" do
    subject do
      settings[:features]
    end

    it "default for ssl returns true" do
      expect(subject[:use_ssl]).to eq(true)
    end

    it "default for home text returns false" do
      expect(subject[:home_text]).to eq(false)
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
end

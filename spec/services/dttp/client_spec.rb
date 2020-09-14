require "rails_helper"

module Dttp
  describe Client do
    it "uses the configured base uri" do
      expect(described_class.base_uri).to eq("https://test-api-base-uri.com")
    end
  end
end

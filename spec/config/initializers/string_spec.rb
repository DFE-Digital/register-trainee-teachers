# frozen_string_literal: true

require "rails_helper"

describe "String" do
  describe "#titleize_with_hyphens" do
    it "titleize the string retaining the hyphen" do
      expect("citizen of guinea-bissau".titleize_with_hyphens).to eq("Citizen Of Guinea-Bissau")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe "String" do
  describe "#to_title" do
    it "titleize the string retaining the hythen" do
      expect("citizen of guinea-bissau".to_title).to eq("Citizen Of Guinea-Bissau")
    end
  end
end

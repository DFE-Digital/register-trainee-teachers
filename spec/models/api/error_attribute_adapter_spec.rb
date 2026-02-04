# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ErrorAttributeAdapter do
  describe "#attribute_mappings" do
    it "does not leak CSV field mappings across API versions" do
      # Call first with the 2025 version to load the CSV field mappings
      expect(Api::V20250::DegreeAttributes.attribute_mappings[:graduation_year]).to eq("Degree graduation year")

      degree_attributes = Api::V20260::DegreeAttributes.new({}, record_source: Trainee::CSV_SOURCE)
      degree_attributes.validate

      expect(Api::V20260::DegreeAttributes.attribute_mappings[:graduation_year]).to eq("degree_graduation_year")
      expect(degree_attributes.errors.full_messages).to include(/degree_graduation_year/)
    end
  end
end

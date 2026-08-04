# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ErrorAttributeAdapter do
  describe "#attribute_mappings" do
    it "maps technical attribute names to the version's CSV field names" do
      expect(Api::V20261::DegreeAttributes.attribute_mappings[:graduation_year]).to eq("degree_graduation_year")
    end

    it "does not leak CSV field mappings across API versions" do
      stub_const("Api::VNEXT::DegreeAttributes", Class.new(Api::V20261::DegreeAttributes))
      stub_const("BulkUpdate::AddTrainees::VNEXT::ImportRows", next_version_import_rows)

      Api::V20261::DegreeAttributes.attribute_mappings

      expect(Api::VNEXT::DegreeAttributes.attribute_mappings[:graduation_year]).to eq("next_version_graduation_year")
      expect(Api::V20261::DegreeAttributes.attribute_mappings[:graduation_year]).to eq("degree_graduation_year")
    end

    def next_version_import_rows
      fields_path = Rails.root.join("spec/fixtures/files/bulk_update/next_version_fields.yaml")

      Class.new do
        define_singleton_method(:fields_definition_path) { fields_path }
      end
    end
  end

  describe "#human_attribute_name" do
    it "names CSV sourced errors after the CSV field" do
      degree_attributes = Api::V20261::DegreeAttributes.new({}, record_source: Trainee::CSV_SOURCE)
      degree_attributes.validate

      expect(degree_attributes.errors.full_messages).to include(/degree_graduation_year/)
    end
  end
end

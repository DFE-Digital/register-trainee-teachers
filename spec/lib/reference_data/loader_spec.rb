# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceData::Loader do
  describe ".load_all" do
    it "loads an array of `ReferenceData::Type`s" do
      types = described_class.load_all
      expect(types).to be_an(Array)
      expect(types.first).to be_a(ReferenceData::Type)
    end

    it "includes the course study mode reference data type" do
      types = described_class.load_all
      study_mode_type = types.find { |type| type.name == "trainee_study_mode" }
      expect(study_mode_type).not_to be_nil
      expect(study_mode_type.values).to include(
        an_object_having_attributes(id: 0, name: "part_time", display_name: "Part-time"),
        an_object_having_attributes(id: 1, name: "full_time", display_name: "Full-time"),
      )
    end
  end

  describe "#find" do
    it "can lookup reference data type by name"
    it "can lookup up values by name within a type"
    it "can lookup up values by id within a type"
    it "can lookup up values by hesa_code within a type"
  end
end

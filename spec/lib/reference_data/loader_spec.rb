# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceData::Loader do
  describe "#types" do
    it "loads an array of `ReferenceData::Type`s" do
      types = described_class.instance.types
      expect(types).to be_an(Array)
      expect(types.first).to be_a(ReferenceData::Type)
    end

    it "includes the course study mode reference data type and it's values" do
      types = described_class.instance.types
      study_mode_type = types.find { |type| type.name == "trainee_study_mode" }
      expect(study_mode_type).not_to be_nil
      expect(study_mode_type.values).to include(
        an_object_having_attributes(id: 0, name: "part_time", display_name: "Part-time"),
        an_object_having_attributes(id: 1, name: "full_time", display_name: "Full-time"),
      )
    end
  end

  describe "#find" do
    it "can lookup reference data type by name" do
      study_mode_type = described_class.instance.find("trainee_study_mode")
      expect(study_mode_type).to be_a(ReferenceData::Type)
      expect(study_mode_type.name).to eq("trainee_study_mode")
    end

    it "returns nil for unknown reference data type names" do
      wheel_size_type = described_class.instance.find("wheel_sizes")
      expect(wheel_size_type).to be_nil
    end
  end
end

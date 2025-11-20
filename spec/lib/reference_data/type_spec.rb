# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceData::Type do
    subject(:type) { ReferenceData::Loader.instance.find("trainee_study_mode") }

  describe "#name" do
    it "has the correct name value" do
      expect(type.name).to eq("trainee_study_mode")
    end
  end

  describe "#display_name" do
    it "has the correct display_name value" do
      expect(type.display_name).to eq("Trainee study mode")
    end
  end

  describe "#values" do
    it "has the correct values" do
      expect(type.values).to include(
        an_object_having_attributes(id: 0, name: "part_time", display_name: "Part-time"),
        an_object_having_attributes(id: 1, name: "full_time", display_name: "Full-time"),
      )
    end
  end

  describe "#find" do
    it "can lookup reference data value by `id`" do
      part_time_value = type.find(0)
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by `id` as a string" do
      part_time_value = type.find('0')
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by name as a symbol" do
      part_time_value = type.find(:part_time)
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "can lookup reference data value by name as a string" do
      part_time_value = type.find("full_time")
      expect(part_time_value).to be_present
      expect(part_time_value).to be_a(ReferenceData::Value)
    end

    it "returns nil for unknown reference data values" do
      expect(type.find("over_time")).to be_nil
    end
  end
end

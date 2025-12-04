# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReferenceData::Value do
  let(:study_modes) { ReferenceData::Loader.instance.find("study_mode") }
  let(:training_routes) { ReferenceData::Loader.instance.find("training_route") }

  describe "#hesa_code" do
    it "raises an error if the hesa_code is ambiguous" do
      expect { study_modes.part_time.hesa_code }.to raise_error(StandardError, "Multiple HESA codes present")
    end

    it "returns the correct hesa_code" do
      expect(training_routes.provider_led_postgrad.hesa_code).to eq("12")
    end

    it "returns nil for values that do not have a hesa_code" do
      expect(training_routes.assessment_only.hesa_code).to be_nil
    end
  end
end

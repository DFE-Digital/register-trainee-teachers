# frozen_string_literal: true

require "rails_helper"

module CodeSets
  describe Trs do
    describe ".training_status" do
      context "when state has a direct mapping" do
        it "returns the correct status for withdrawn" do
          expect(described_class.training_status("withdrawn", "assessment_only")).to eq("Withdrawn")
        end

        it "returns the correct status for deferred" do
          expect(described_class.training_status("deferred", "provider_led_postgrad")).to eq("Deferred")
        end

        it "returns the correct status for awarded" do
          expect(described_class.training_status("awarded", "school_direct")).to eq("Awarded")
        end

        it "returns the correct status for recommended_for_award" do
          expect(described_class.training_status("recommended_for_award", "teach_first")).to eq("Awarded")
        end
      end

      context "when state is in training or submitted for trn" do
        it "returns UnderAssessment for assessment_only route" do
          expect(described_class.training_status("trn_received", "assessment_only")).to eq("UnderAssessment")
          expect(described_class.training_status("submitted_for_trn", "assessment_only")).to eq("UnderAssessment")
        end

        it "returns InTraining for non-assessment_only routes" do
          expect(described_class.training_status("trn_received", "provider_led_postgrad")).to eq("InTraining")
          expect(described_class.training_status("submitted_for_trn", "school_direct")).to eq("InTraining")
        end
      end

      context "when state has no mapping" do
        it "returns nil" do
          expect(described_class.training_status("draft", "provider_led_postgrad")).to be_nil
        end
      end
    end
  end
end

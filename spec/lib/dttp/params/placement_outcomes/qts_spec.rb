# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    module PlacementOutcomes
      describe Qts do
        subject { described_class.new(trainee: trainee).params }

        let(:trainee) { build(:trainee, outcome_date: "1/1/2021") }

        describe "params" do
          describe "date left" do
            it "is set to outcome_date" do
              # TODO: this will be different for non-assessment only routes
              expect(subject["dfe_dateleft"]).to eq(trainee.outcome_date.in_time_zone.iso8601)
            end
          end

          describe "dfe_datestandardsassessmentpassed" do
            it "is set to outcome_date" do
              expect(subject["dfe_datestandardsassessmentpassed"]).to eq(trainee.outcome_date.in_time_zone.iso8601)
            end
          end

          describe "dfe_StandardAssessedId" do
            it "is set as STANDARDS_PASSED" do
              expect(subject["dfe_StandardAssessedId@odata.bind"]).to eq("/dfe_standardassesseds(#{described_class::STANDARDS_PASSED})")
            end
          end

          describe "dfe_ReasonforLeavingId" do
            it "is set as SUCCESSFUL_COMPLETION_OF_COURSE" do
              expect(subject["dfe_ReasonforLeavingId@odata.bind"]).to eq("/dfe_reasonforleavings(#{described_class::SUCCESSFUL_COMPLETION_OF_COURSE})")
            end
          end

          describe "dfe_recommendraineetonctl" do
            it "is set to true" do
              expect(subject["dfe_recommendtraineetonctl"]).to eq(true)
            end
          end
        end

        describe "to_json" do
          subject { described_class.new(trainee: trainee) }

          it "returns params to_json" do
            expect(subject.to_json).to eq(subject.params.to_json)
          end
        end
      end
    end
  end
end

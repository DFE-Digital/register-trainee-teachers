# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    module PlacementOutcomes
      describe Withdrawn do
        subject { described_class.new(trainee: trainee).params }

        let(:trainee) { build(:trainee, :withdrawn_for_specific_reason) }

        describe "params" do
          describe "date left" do
            it "is set to the trainee's withdrawal date" do
              expect(subject["dfe_dateleft"]).to eq(trainee.withdraw_date.in_time_zone.iso8601)
            end
          end

          describe "dfe_datestandardsassessmentpassed" do
            before do
              trainee.outcome_date = "1/1/2021"
            end

            it "is set to the trainee outcome_date if it exists" do
              expect(subject["dfe_datestandardsassessmentpassed"]).to eq(trainee.outcome_date.in_time_zone.iso8601)
            end
          end

          describe "dfe_ReasonforLeavingId" do
            let(:dttp_reason_for_leaving_id) { Dttp::CodeSets::ReasonsForLeavingCourse::MAPPING[trainee.withdraw_reason][:entity_id] }

            it "is set as the trainee's withdrawl reason" do
              expect(subject["dfe_ReasonforLeavingId@odata.bind"]).to eq("/dfe_reasonforleavings(#{dttp_reason_for_leaving_id})")
            end
          end

          describe "dfe_ITTQualificationAimId" do
            it "is set as NO_QUALIFICATION_OBTAINED_ON_EXIT" do
              expect(subject["dfe_ITTQualificationAimId@odata.bind"]).to eq("/dfe_ittqualificationaims(#{described_class::NO_QUALIFICATION_OBTAINED_ON_EXIT})")
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

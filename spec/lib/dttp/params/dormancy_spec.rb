# frozen_string_literal: true

require "rails_helper"

module Dttp
  module Params
    describe Dormancy do
      subject { described_class.new(trainee: trainee).params }

      let(:trainee) { build(:trainee, :with_placement_assignment, :deferred) }

      describe "params" do
        describe "dfe_dateleftcourse" do
          it "is set to the deferral date" do
            expect(subject["dfe_dateleftcourse"]).to eq(trainee.defer_date.in_time_zone.iso8601)
          end
        end

        describe "dfe_datereturnedtocourse" do
          let(:trainee) { build(:trainee, :with_placement_assignment, :deferred, :reinstated) }

          it "is set to reinstated date" do
            expect(subject["dfe_datereturnedtocourse"]).to eq(trainee.reinstate_date.in_time_zone.iso8601)
          end
        end

        describe "dfe_TrainingRecordId" do
          it "is set to the trainee's placement_assignment_dttp_id" do
            expect(subject["dfe_TrainingRecordId@odata.bind"]).to eq("/dfe_placementassignments(#{trainee.placement_assignment_dttp_id})")
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

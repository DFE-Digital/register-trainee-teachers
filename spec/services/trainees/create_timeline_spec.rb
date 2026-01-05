# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateTimeline do
    let(:trainee) { create(:trainee) }
    let(:audits) { trainee.own_and_associated_audits }

    subject { described_class.call(trainee: trainee, current_user: nil) }

    describe "#call" do
      context "when a trainee is updated but not yet submitted for trn" do
        before do
          update_name
        end

        it "returns just the creation audit" do
          expect(subject.map(&:title)).to contain_exactly("Record created")
        end
      end

      context "when a trainee has been submitted for trn" do
        before do
          trainee.submit_for_trn!
        end

        it "returns the creation audit and the trn audit" do
          expect(subject.map(&:title)).to contain_exactly(
            "Record created",
            "Trainee submitted for TRN",
          )
        end

        context "and a subsequent update is made" do
          before do
            Timecop.travel(1.hour.from_now) { update_name }
          end

          it "returns the creation audit and the trn audit" do
            expect(subject.map(&:title)).to contain_exactly(
              "Record created",
              "Trainee submitted for TRN",
              "First names updated",
            )
          end
        end

        it "returns the events in reverse order" do
          expected_order = trainee.own_and_associated_audits.pluck(:created_at).sort.reverse.map(&:to_i)

          expect(subject.map(&:date).map(&:to_i)).to eq(expected_order)
        end

        context "when a degree has been created and deleted" do
          before do
            Audited.audit_class.as_user(nil) do
              create(:degree, trainee:)
              trainee.reload.degrees.destroy_all
            end
          end

          it "returns the events" do
            expect(trainee.own_and_associated_audits.count).to eq(4)
            expect(trainee.own_and_associated_audits.where(auditable_type: "Degree").pluck(:action)).to contain_exactly("create", "destroy")
            expect(subject.map(&:title)).to contain_exactly(
              "Record created",
              "Trainee submitted for TRN",
              "Degree added",
              "Degree deleted",
            )
          end
        end

        context "when a degree has been created and deleted via HESA" do
          before do
            Audited.audit_class.as_user(::Trainee::HESA_USERNAME) do
              create(:degree, trainee:)
              trainee.reload.degrees.destroy_all
            end
          end

          it "does not return the events" do
            expect(trainee.own_and_associated_audits.count).to eq(4)
            expect(trainee.own_and_associated_audits.where(auditable_type: "Degree").pluck(:action)).to contain_exactly("create", "destroy")
            expect(subject.map(&:title)).to contain_exactly(
              "Record created",
              "Trainee submitted for TRN",
            )
          end
        end
      end

      context "when a trainee has been withdrawn" do
        let!(:trainee_withdrawal) { create(:trainee_withdrawal, trainee: trainee, date: "2021-09-21") }

        before do
          trainee.submit_for_trn!
          trainee.withdraw!
        end

        it "returns the date of withdrawal in the correct format and reason" do
          expect(subject.first.items).to eq([["Date of withdrawal:", "21 September 2021"]])
        end
      end

      context "when a placement has been created, updated and deleted" do
        let(:school) { create(:school) }
        let(:new_school) { create(:school) }
        let(:placement) { create(:placement, school:, trainee:) }

        before do
          trainee.update_column(:submitted_for_trn_at, 10.days.ago)
          placement.update!(school: new_school)
          placement.destroy!
        end

        it "returns each of the CRUD events" do
          expect(trainee.own_and_associated_audits.count).to eq(4)
          expect(subject.map(&:title)).to contain_exactly(
            "Record created",
            "Placement at #{school.name} added",
            "Placement changed from #{school.name} to #{new_school.name}",
            "Placement at #{placement.name} removed",
          )
        end
      end

      context "when multiple placements have been created in the same request" do
        let!(:trainee) { create(:trainee) }
        let!(:placement_one) { create(:placement, trainee:) }
        let!(:placement_two) { create(:placement, trainee:) }

        before do
          trainee.update_column(:submitted_for_trn_at, 1.day.ago)
          ::Audited::Audit.where(auditable_type: Placement.name).update_all(request_uuid: SecureRandom.uuid)
        end

        it "returns all the placement events" do
          expect(trainee.own_and_associated_audits.where(auditable_type: Placement.name).count).to eq(2)
          expect(subject.map(&:title)).to contain_exactly(
            "Record created",
            "Placement at #{placement_one.name} added",
            "Placement at #{placement_two.name} added",
          )
        end
      end
    end

    def update_name
      trainee.update!(first_names: "name")
    end
  end
end

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
          reload_audits
        end

        it "returns just the creation audit" do
          expect(subject.count).to eq(1)
        end
      end

      context "when a trainee has been submitted for trn" do
        before do
          trainee.submit_for_trn!
          reload_audits
        end

        it "returns the creation audit and the trn audit" do
          expect(subject.count).to eq(2)
        end

        context "and a subsequent update is made" do
          before do
            Timecop.travel(1.hour.from_now) { update_name }
            reload_audits
          end

          it "returns the creation audit and the trn audit" do
            expect(subject.count).to eq(3)
          end
        end

        it "returns the events in reverse order" do
          expected_order = trainee.own_and_associated_audits.pluck(:created_at).sort.reverse
          expect(subject.map(&:date)).to eq(expected_order)
        end
      end

      context "when a trainee has been withdrawn" do
        let(:trainee) { create(:trainee, :trn_received) }

        before do
          trainee.withdraw_date = "2021-09-21"
          trainee.withdraw!
        end

        it "returns the date of withdrawal in the correct format and reason" do
          expect(subject.first.items).to eq([["Date of withdrawal:", "21 September 2021"]])
        end
      end

      context "when a degree has been created and deleted via HESA" do
        before do
          Audited.audit_class.as_user(::Trainees::CreateFromHesa::USERNAME) do
            create(:degree, trainee:)
            trainee.reload.degrees.destroy_all
            reload_audits
          end
        end

        it "does not return the events" do
          expect(trainee.own_and_associated_audits.count).to eq(3)
          expect(trainee.own_and_associated_audits.where(auditable_type: "Degree").pluck(:action)).to contain_exactly("destroy", "create")
          expect(subject.count).to eq(1)
        end
      end

      context "when a placement has been created, updated and deleted" do
        before do
          trainee.update_column(:submitted_for_trn_at, 10.days.ago)
          placement = create(:placement, trainee:)
          placement.update(school: create(:school))
          placement.destroy
          reload_audits
        end

        it "returns each of the CRUD events" do
          expect(trainee.own_and_associated_audits.count).to eq(4)
          expect(subject.count).to eq(4)
        end
      end

      context "when multiple placements have been created in the same request" do
        let(:trainee) { create(:trainee) }

        before do
          create(:placement, trainee:)
          create(:placement, trainee:)
          trainee.update_column(:submitted_for_trn_at, 1.day.ago)
          ::Audited::Audit.where(auditable_type: Placement.name).update_all(request_uuid: SecureRandom.uuid)
          reload_audits
        end

        it "returns all the placement events" do
          expect(trainee.own_and_associated_audits.where(auditable_type: Placement.name).count).to eq(2)
          expect(subject.count).to eq(3)
        end
      end
    end

    def update_name
      trainee.update!(first_names: "name")
    end

    def reload_audits
      trainee.own_and_associated_audits.each do |audit|
        allow(CreateTimelineEvents).to receive(:call).with(audit: audit, current_user: nil).and_return(double(title: "title", date: audit.created_at))
      end
    end
  end
end

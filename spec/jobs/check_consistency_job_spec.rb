# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe CheckConsistencyJob do
    let(:trainee) { build(:trainee, id: 1) }
    let(:contact) { double({ updated_on: "2021-03-29 16:00:00.000000 +0100" }) }
    let(:placement_assignment) { double({ updated_at: "2021-03-29 16:00:00.000000 +0100" }) }
    subject { described_class.perform_now(consistency_check.id) }

    before do
      allow(Dttp::Contacts::Fetch).to receive(:call).with({ trainee: trainee }) { contact }
      allow(Dttp::PlacementAssignments::Fetch).to receive(:call).with({ placement_assignment_dttp_id: trainee.placement_assignment_dttp_id }) { placement_assignment }
      allow(SlackNotifierService).to receive(:call) { "foobar" }
      allow(Trainee).to receive(:find).with(trainee.id) { trainee }
    end

    context "in sync" do
      let(:consistency_check) do
        create(:consistency_check,
               trainee_id: trainee.id,
               contact_last_updated_at: contact.updated_on,
               placement_assignment_last_updated_at: placement_assignment.updated_at)
      end

      it "it will not do anything" do
        expect(SlackNotifierService).to_not receive(:call)
        subject
      end
    end

    context "out of sync" do
      let(:consistency_check) do
        create(:consistency_check,
               trainee_id: trainee.id,
               contact_last_updated_at: (Time.zone.now - 1.day),
               placement_assignment_last_updated_at: (Time.zone.now - 1.day))
      end

      it "it will throw an error and notify slack" do
        expect(SlackNotifierService).to receive(:call)
        subject
      end
    end
  end
end

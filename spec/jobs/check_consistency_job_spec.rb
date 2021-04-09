# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe CheckConsistencyJob do
    let(:trainee) { create(:trainee, dttp_id: SecureRandom.uuid) }
    let(:contact) { double({ updated_at: Faker::Date.backward(days: 2) }) }
    let(:placement_assignment) { double({ updated_at: Faker::Date.backward(days: 2) }) }
    subject { described_class.perform_now(consistency_check.id) }

    before do
      allow(Dttp::Contacts::Fetch).to receive(:call).with(dttp_id: trainee.dttp_id) { contact }
      allow(Dttp::PlacementAssignments::Fetch).to receive(:call).with(dttp_id: trainee.placement_assignment_dttp_id) { placement_assignment }
      allow(SlackNotifierService).to receive(:call) { "foobar" }
      allow(Trainee).to receive(:find).with(trainee.id) { trainee }
    end

    context "when in sync" do
      let(:consistency_check) do
        create(:consistency_check,
               trainee_id: trainee.id,
               contact_last_updated_at: contact.updated_at,
               placement_assignment_last_updated_at: placement_assignment.updated_at)
      end

      it "does nothing" do
        expect(SlackNotifierService).to_not receive(:call)
        subject
      end
    end

    context "when out of sync" do
      let(:consistency_check) do
        create(:consistency_check,
               trainee_id: trainee.id,
               contact_last_updated_at: Faker::Date.in_date_period,
               placement_assignment_last_updated_at: Faker::Date.in_date_period)
      end

      it "notifies slack" do
        expect(SlackNotifierService).to receive(:call)
        subject
      end
    end
  end
end

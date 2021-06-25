# frozen_string_literal: true

require "rails_helper"

describe CreateOrUpdateConsistencyCheckJob do
  include ActiveJob::TestHelper
  let(:trainee) { create(:trainee, :submitted_for_trn) }
  let(:contact) { double({ updated_at: Faker::Date.backward(days: 2) }) }
  let(:placement_assignment) { double({ updated_at: Faker::Date.backward(days: 2) }) }

  subject { described_class.perform_now(trainee) }

  before do
    allow(Dttp::Contacts::Fetch).to receive(:call) { contact }
    allow(Dttp::PlacementAssignments::Fetch).to receive(:call) { placement_assignment }
  end

  describe ".perform" do
    context "when the trainee is draft" do
      let(:trainee) { create(:trainee, :draft) }

      it "is a noop" do
        expect { subject }.not_to(change { ConsistencyCheck.count })
      end
    end

    context "when a check doesn't exist" do
      it "creates a consistency check" do
        expect { subject }.to change { ConsistencyCheck.count }.from(0).to(1)
      end
    end

    context "when a check exists" do
      let(:old_consistency_check) do
        create(:consistency_check,
               trainee_id: trainee.id,
               contact_last_updated_at: Faker::Date.backward(days: 1),
               placement_assignment_last_updated_at: Faker::Date.backward(days: 1))
      end

      it "won't make duplicate checks" do
        subject
        expect { subject }.not_to(change { ConsistencyCheck.count })
      end

      it "will update the check" do
        old_consistency_check
        subject
        expect(
          ConsistencyCheck.where(
            trainee_id: trainee.id,
          ).first.contact_last_updated_at,
        ).to eq contact.updated_at
        expect(
          ConsistencyCheck.where(
            trainee_id: trainee.id,
          ).first.placement_assignment_last_updated_at,
        ).to eq placement_assignment.updated_at
      end
    end
  end
end

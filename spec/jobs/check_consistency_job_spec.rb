# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe CheckConsistencyJob do
    let(:contact) { create(:contact) }
    let(:placement_assignment) { create(:placement_assignment) }
    let(:consistency_check) { create(:consistency_check) }
    subject { described_class.perform_now(consistency_check.id) }

    before do
      allow(Dttp::Contacts::Fetch).to receive(:call) { contact }
      allow(Dttp::PlacementAssignments::Fetch).to receive(:call) { placement_assignment }
    end

    context "in sync" do
      pending "it will not do anything" do
        expect { subject }.to be_valid
      end
    end

    context "out of sync" do
      pending "it will throw an error and notify slack" do
      end
    end
  end
end

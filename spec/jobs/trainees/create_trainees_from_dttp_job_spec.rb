# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttpJob do
    include ActiveJob::TestHelper
    let(:dttp_trainee) { create(:dttp_trainee, :with_provider, :with_placement_assignment) }

    describe "#perform", feature_import_trainees_from_dttp: true do
      it "calls the CreateFromDttp service" do
        expect(CreateFromDttp).to receive(:call).with(dttp_trainee: dttp_trainee)
        described_class.perform_now(dttp_trainee)
      end

      it "creates audits with the 'DTTP' user" do
        described_class.perform_now(dttp_trainee)
        expect(Trainee.last.audits.first.username).to eq("DTTP")
      end
    end
  end
end

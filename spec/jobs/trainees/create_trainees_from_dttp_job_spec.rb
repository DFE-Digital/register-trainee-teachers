# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe CreateFromDttpJob do
    include ActiveJob::TestHelper
    let(:dttp_trainee) { create(:dttp_trainee) }

    describe "#perform", feature_import_trainees_from_dttp: true do
      it "calls the CreateFromDttp service" do
        expect(CreateFromDttp).to receive(:call).with(dttp_trainee: dttp_trainee)

        described_class.perform_now(dttp_trainee)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module RecruitsApi
  describe ImportApplicationJob do
    include ActiveJob::TestHelper

    let(:application_data) { double("application_data") }

    context "when ImportApplication returns RecruitsApiMissingDataError" do
      before do
        allow(ImportApplication).to receive(:call).with(application_data:).and_raise RecruitsApi::ImportApplication::RecruitsApiMissingDataError
      end

      it "is rescued and captured by Sentry" do
        expect(Sentry).to receive(:capture_exception).with(RecruitsApi::ImportApplication::RecruitsApiMissingDataError)
        described_class.perform_now(application_data)
      end
    end
  end
end

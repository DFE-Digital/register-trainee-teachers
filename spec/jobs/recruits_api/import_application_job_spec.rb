# frozen_string_literal: true

require "rails_helper"

module RecruitsApi
  describe ImportApplicationJob do
    include ActiveJob::TestHelper

    let(:application_data) { double("application_data") }

    context "when ImportApplication returns ApplyApiMissingDataError" do
      before do
        allow(ImportApplication).to receive(:call).with(application_data:).and_raise ApplyApi::ImportApplication::ApplyApiMissingDataError
      end

      it "is rescued and captured by Sentry" do
        expect(Sentry).to receive(:capture_exception).with(ApplyApi::ImportApplication::ApplyApiMissingDataError)
        described_class.perform_now(application_data)
      end
    end
  end
end

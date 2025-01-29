# frozen_string_literal: true

require "rails_helper"

module Trs
  describe RegisterForTrnJob do
    describe "#perform_now" do
      let(:trainee) { create(:trainee, :draft) }

      before do
        enable_features(:integrate_with_trs)
      end

      it "calls RegisterForTrn if feature is enabled and trn is not present" do
        expect(Trs::RegisterForTrn).to(receive(:call).with(trainee:))
        described_class.perform_now(trainee)
      end

      it "does not call RegisterForTrn if feature is disabled" do
        allow(FeatureService).to(receive(:enabled?).with(:integrate_with_trs).and_return(false))
        expect(Trs::RegisterForTrn).not_to(receive(:call))
        described_class.perform_now(trainee)
      end

      it "does not call RegisterForTrn if trn is present" do
        trainee.update(trn: 1234567)
        expect(Trs::RegisterForTrn).not_to(receive(:call))
        described_class.perform_now(trainee)
      end
    end
  end
end

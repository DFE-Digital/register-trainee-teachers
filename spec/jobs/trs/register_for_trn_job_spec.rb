# frozen_string_literal: true

require "rails_helper"

module Trs
  describe RegisterForTrnJob do
    describe "#perform_now" do
      let(:trainee) { create(:trainee, :draft) }
      let(:trn_request) { create(:trs_trn_request, trainee:) }

      before do
        enable_features(:integrate_with_trs)
      end

      it "calls RegisterForTrn if feature is enabled and trn is not present" do
        expect(Trs::RegisterForTrn).to(receive(:call).with(trainee:))
        described_class.perform_now(trainee)
      end

      it "does not call RegisterForTrn if feature is disabled" do
        disable_features(:integrate_with_trs)
        expect(Trs::RegisterForTrn).not_to(receive(:call))
        described_class.perform_now(trainee)
      end

      it "does not call RegisterForTrn if trn is present" do
        trainee.update(trn: 1234567)
        expect(Trs::RegisterForTrn).not_to(receive(:call))
        described_class.perform_now(trainee)
      end

      it "calls RetrieveTrnJob with a 1-minute delay if trn_request is not failed" do
        allow(RegisterForTrn).to(receive(:call).with(trainee:).and_return(trn_request))
        allow(trn_request).to(receive(:failed?).and_return(false))

        retrieve_job = instance_double(ActiveJob::ConfiguredJob)
        allow(RetrieveTrnJob).to(receive(:set).with(wait: 1.minute).and_return(retrieve_job))
        expect(retrieve_job).to(receive(:perform_later).with(trn_request))

        described_class.perform_now(trainee)
      end

      it "does not call RetrieveTrnJob if trn_request is failed" do
        allow(RegisterForTrn).to(receive(:call).with(trainee:).and_return(trn_request))
        allow(trn_request).to(receive(:failed?).and_return(true))

        expect(RetrieveTrnJob).not_to(receive(:set))
        expect(RetrieveTrnJob).not_to(receive(:perform_later))
        described_class.perform_now(trainee)
      end
    end
  end
end

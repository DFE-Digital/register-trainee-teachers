# frozen_string_literal: true

require "rails_helper"

module Hesa
  describe UploadTrnFileJob do
    let!(:academic_cycle) { create(:academic_cycle, :current) }

    context "feature flag is off" do
      before { disable_features(:hesa_trn_requests) }

      it "doesn't create a Hesa::TrnSubmission record" do
        expect { described_class.new.perform }.not_to change { Hesa::TrnSubmission.count }
      end

      it "doesn't call the HESA API" do
        expect(Hesa::Client).not_to receive(:upload_trn_file)
        described_class.new.perform
      end
    end

    context "feature flag is on" do
      before do
        enable_features(:hesa_trn_requests)
        allow(UploadTrnFile).to receive(:call)
      end

      it "uploads file and saves logs payload" do
        expect { described_class.new.perform }.to change { TrnSubmission.count }.by(1)
      end

      context "upload error" do
        let(:hesa_upload_error) { Hesa::UploadTrnFile::TrnFileUploadError.new }

        before do
          allow(Hesa::UploadTrnFile).to receive(:call).and_raise(hesa_upload_error)
        end

        it "sends an error message to Sentry" do
          expect(Sentry).to receive(:capture_exception).with(hesa_upload_error)
          described_class.new.perform
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe FundingUpload do
    subject { build(:funding_upload) }

    it { is_expected.to be_valid }

    describe "scopes" do
      describe ".recently_processed_upload_for" do
        let!(:older_processed_funding_upload) { create(:funding_upload, :processed, :training_partner_trainee_summaries, created_at: 1.day.ago) }
        let!(:recently_processed_funding_upload) { create(:funding_upload, :training_partner_trainee_summaries, :processed) }
        let!(:pending_funding_upload) { create(:funding_upload, :training_partner_trainee_summaries) }
        let!(:failed_funding_upload) { create(:funding_upload, :failed, :training_partner_trainee_summaries) }

        it "returns recently processed funding uploads" do
          expect(described_class.recently_processed_upload_for(:training_partner_trainee_summary)).to eq(recently_processed_funding_upload)
        end
      end
    end

    describe "events" do
      subject { create(:funding_upload) }

      describe "#process!" do
        it do
          expect {
            subject.process!
          }.to change(subject, :status).from("pending").to("processed")
        end
      end

      describe "#fail!" do
        context "when an error is passed" do
          it "sets the status to failed with the error class and message" do
            expect {
              subject.fail!(ArgumentError.new("something went wrong"))
            }.to change(subject, :status).from("pending").to("failed")

            expect(subject.reload.error_message).to eq("ArgumentError: something went wrong")
          end
        end

        context "when no error is passed" do
          it "sets the status to failed without an error message" do
            expect {
              subject.fail!
            }.to change(subject, :status).from("pending").to("failed")

            expect(subject.reload.error_message).to be_nil
          end
        end
      end
    end
  end
end

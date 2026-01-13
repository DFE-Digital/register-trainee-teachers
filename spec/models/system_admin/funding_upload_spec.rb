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
  end
end

# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe ChangeAccreditedProviderForm, type: :model do
    let(:params) { {} }
    let(:new_provider) { create(:provider) }
    let(:old_provider) { create(:provider) }
    let(:trainee) { create(:trainee, :trn_received, provider: old_provider) }
    let(:form_store_params) { nil }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(form_store_params)
      allow(form_store).to receive(:set).with(trainee.id, :change_accredited_provider, nil)
    end

    describe "validations" do
      context "provider id not given" do
        let(:params) do
          {
            audit_comment: "The old provider has stopped offering this course",
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "timeline comment not given" do
        let(:params) do
          {
            accredited_provider_id: 12345,
          }
        end

        it { is_expected.not_to be_valid }
      end

      context "timeline comment and provider id are given" do
        let(:params) do
          {
            accredited_provider_id: 12345,
            audit_comment: "The old provider has stopped offering this course",
          }
        end

        it { is_expected.to be_valid }
      end
    end

    describe "#save!" do
      let(:accredited_provider_id) { new_provider.id }
      let(:audit_comment) { "The old provider has stopped offering this course" }
      let(:zendesk_ticket_url) { "https://zendesk.com/123456" }

      let(:form_store_params) { { accredited_provider_id:, audit_comment:, zendesk_ticket_url: } }

      context "with valid inputs" do
        before { subject.save! }

        it "updates the trainee's provider" do
          expect(trainee.reload.provider).to eq(new_provider)
        end

        it "attaches an audit comment to the update" do
          last_audit_entry = trainee.reload.audits.last
          expect(last_audit_entry.comment).to match(/Accredited provider updated/)
          expect(last_audit_entry.comment).to match(audit_comment)
          expect(last_audit_entry.comment).to match(zendesk_ticket_url)
        end
      end

      context "with invalid inputs" do
        let(:audit_comment) { "" }

        before { subject.save! }

        it "is does not change the trainee's provider" do
          expect(trainee.reload.provider).to eq(old_provider)
        end
      end
    end
  end
end

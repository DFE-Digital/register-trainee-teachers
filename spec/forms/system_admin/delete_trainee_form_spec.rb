# frozen_string_literal: true

require "rails_helper"

module SystemAdmin
  describe DeleteTraineeForm, type: :model do
    let(:params) { {} }
    let(:trainee) { create(:trainee, :trn_received) }
    let(:form_store_params) { nil }
    let(:form_store) { class_double(FormStore) }
    let(:delete_reason) { described_class::DELETE_REASONS.sample }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(form_store_params)
      allow(form_store).to receive(:set).with(trainee.id, :delete_trainee, nil)
    end

    describe "validations" do
      context "delete reason not given" do
        it { is_expected.not_to be_valid }
      end

      context "specific delete reason given" do
        let(:params) { { delete_reason: } }

        it { is_expected.to be_valid }
      end

      context "another reason specified but not given" do
        let(:params) { { delete_reason: described_class::ANOTHER_REASON } }

        it { is_expected.not_to be_valid }
      end

      context "another reason is specified" do
        let(:params) { { delete_reason: described_class::ANOTHER_REASON, additional_delete_reason: "something" } }

        it { is_expected.to be_valid }
      end
    end

    describe "#save!" do
      let(:ticket) { "http://example.org" }
      let(:form_store_params) { { "delete_reason" => delete_reason, "ticket" => ticket } }

      before { subject.save! }

      it "updates the trainee's discarded_at field" do
        expect(trainee.discarded_at).not_to be_nil
      end

      it "adds the delete reason to audit trail" do
        expect(trainee.audits.last.comment).to eq("#{delete_reason}\n#{ticket}")
      end
    end
  end
end

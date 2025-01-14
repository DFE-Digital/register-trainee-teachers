# frozen_string_literal: true

require "rails_helper"

module Withdrawal
  describe ReasonForm, type: :model do
    let(:params) { { reason_ids: [1, 2] } }
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:reason_ids) }
    end

    describe "#stash" do
      it "uses FormStore to temporarily save the fields under a key combination of trainee withdrawal ID and future interest" do
        expect(form_store).to receive(:set).with(trainee.id, :withdrawal_reasons, { reason_ids: [1, 2], another_reason: nil })

        subject.stash
      end
    end

    describe "#reasons" do
      before do
        WithdrawalReason.upsert_all(WithdrawalReasons::SEED, unique_by: :name)
        allow(subject).to receive(:provider_triggered?).and_return(provider_triggered)
      end

      context "when the trigger is provider" do
        let(:provider_triggered) { true }

        it "returns provider triggered withdrawal reasons in order" do
          expect(subject.reasons.pluck(:name)).to match_array(WithdrawalReasons::PROVIDER_REASONS)
        end
      end

      context "when the trigger is trainee" do
        let(:provider_triggered) { false }

        it "returns provider triggered withdrawal reasons in order" do
          expect(subject.reasons.pluck(:name)).to match_array(WithdrawalReasons::TRAINEE_REASONS)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Withdrawal
  describe ReasonForm, type: :model do
    let(:params) { { reason_ids: [1, 2] } }
    let(:trainee) { create(:trainee) }
    let(:form_store) { class_double(FormStore) }

    subject { described_class.new(trainee, params: params, store: form_store) }

    before do
      WithdrawalReason.upsert_all(WithdrawalReasons::SEED, unique_by: :name)
      allow(form_store).to receive(:get).and_return(nil)
    end

    describe "validations" do
      let(:params) { { reason_ids: [] } }
      let(:trigger_form) { instance_double(Withdrawal::TriggerForm, trigger:) }

      before do
        allow(Withdrawal::TriggerForm).to receive(:new).and_return(trigger_form)
      end

      context "when provider has withdrawn the trainee" do
        let(:trigger) { "provider" }

        it "provides the correct error message" do
          subject.validate

          expect(subject.errors[:reason_ids]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.provider.blank"))
        end
      end

      context "when the trainee has chosen to withdraw" do
        let(:trigger) { "trainee" }

        it "provides the correct error message" do
          subject.validate

          expect(subject.errors[:reason_ids]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.trainee.blank"))
        end
      end

      context "when the trigger is provider" do
        let(:trigger) { "provider" }

        context "with a reason from the trainee-only list" do
          let(:reason_id) { WithdrawalReason.where(name: WithdrawalReasons::DOES_NOT_WANT_TO_BECOME_A_TEACHER).first.id }
          let(:params) { { reason_ids: [reason_id] } }

          it "provides the correct error message" do
            subject.validate

            expect(subject.errors[:reason_ids]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.invalid"))
          end
        end

        context "with a reason from the provider list" do
          let(:reason_id) { WithdrawalReason.where(name: WithdrawalReasons::PROVIDER_REASONS.first).first.id }
          let(:params) { { reason_ids: [reason_id] } }

          it "is valid" do
            expect(subject).to be_valid
          end
        end

        context "with a reason id that does not exist" do
          let(:params) { { reason_ids: [-1] } }

          it "provides the correct error message" do
            subject.validate

            expect(subject.errors[:reason_ids]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.invalid"))
          end
        end
      end

      context "when the trigger is trainee" do
        let(:trigger) { "trainee" }

        context "with a reason from the provider-only list" do
          let(:reason_id) { WithdrawalReason.where(name: WithdrawalReasons::RECORD_ADDED_IN_ERROR).first.id }
          let(:params) { { reason_ids: [reason_id] } }

          it "provides the correct error message" do
            subject.validate

            expect(subject.errors[:reason_ids]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.reason_ids.invalid"))
          end
        end

        context "with a reason from the trainee list" do
          let(:reason_id) { WithdrawalReason.where(name: WithdrawalReasons::TRAINEE_REASONS.first).first.id }
          let(:params) { { reason_ids: [reason_id] } }

          it "is valid" do
            expect(subject).to be_valid
          end
        end
      end

      context "when another reason has been chosen" do
        let(:trigger) { "trainee" }
        let(:another_reason_id) { WithdrawalReason.where(name: "trainee_chose_to_withdraw_another_reason").first.id }
        let(:params) { { reason_ids: [another_reason_id], another_reason: another_reason } }

        context "when the reason provided is blank" do
          let(:another_reason) { "" }

          it "provides the correct error message" do
            subject.validate

            expect(subject.errors[:another_reason]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.another_reason.blank"))
          end
        end
      end

      context "when safeguarding concern has been chosen" do
        let(:trigger) { "trainee" }
        let(:safeguarding_reason_id) { WithdrawalReason.where(name: "safeguarding_concerns").first.id }
        let(:params) { { reason_ids: [safeguarding_reason_id], safeguarding_concern_reasons: safeguarding_concern_reasons } }

        context "when the reason provided is blank" do
          let(:safeguarding_concern_reasons) { "" }

          it "provides the correct error message" do
            subject.validate

            expect(subject.errors[:safeguarding_concern_reasons]).to include(I18n.t("activemodel.errors.models.withdrawal/reason_form.attributes.safeguarding_concern_reasons.blank"))
          end
        end
      end
    end

    describe "#stash" do
      let(:reason_ids) { WithdrawalReason.where(name: WithdrawalReasons::TRAINEE_REASONS.first(2)).ids }
      let(:params) { { reason_ids: } }

      it "uses FormStore to temporarily save the fields under a key combination of trainee withdrawal ID and future interest" do
        expect(form_store).to receive(:set).with(trainee.id, :withdrawal_reasons, { reason_ids: reason_ids, another_reason: nil })

        subject.stash
      end
    end

    describe "#reasons" do
      let(:trigger_form) { instance_double(Withdrawal::TriggerForm, trigger:) }

      before do
        allow(Withdrawal::TriggerForm).to receive(:new).and_return(trigger_form)
      end

      context "when the trigger is provider" do
        let(:trigger) { "provider" }

        it "returns provider triggered withdrawal reasons in order" do
          expect(subject.reasons.pluck(:name)).to match_array(WithdrawalReasons::PROVIDER_REASONS)
        end
      end

      context "when the trigger is trainee" do
        let(:trigger) { "trainee" }

        it "returns trainee triggered withdrawal reasons in order" do
          expect(subject.reasons.pluck(:name)).to match_array(WithdrawalReasons::TRAINEE_REASONS)
        end
      end
    end
  end
end

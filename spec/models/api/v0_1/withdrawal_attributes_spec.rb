# frozen_string_literal: true

require "rails_helper"

describe Api::V01::WithdrawalAttributes do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:withdrawal_attributes) { described_class.new(trainee:) }

  subject { withdrawal_attributes }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:trigger).in_array(%w[provider trainee]).with_message("is not included in the list") }
    it { is_expected.to validate_inclusion_of(:future_interest).in_array(%w[yes no unknown]).with_message("is not included in the list") }

    context "withdraw_date" do
      context "blank date" do
        before do
          subject.withdraw_date = nil
          subject.validate
        end

        it "is blank" do
          expect(subject.errors[:withdraw_date]).to contain_exactly(
            "Choose a withdrawal date",
          )
        end
      end

      context "invalid date" do
        before do
          subject.withdraw_date = "14/11/23"
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:withdraw_date]).to contain_exactly(
            "Choose a valid withdrawal date",
          )
        end
      end
    end

    context "reasons" do
      context "with no trigger" do
        before do
          subject.trigger = nil
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:reasons]).to contain_exactly(
            "Choose a reason for withdrawal",
          )
        end
      end

      context "with trigger" do
        let(:trainee_reason) { (WithdrawalReasons::TRAINEE_REASONS - WithdrawalReasons::PROVIDER_REASONS).first }
        let(:provider_reason) { (WithdrawalReasons::PROVIDER_REASONS - WithdrawalReasons::TRAINEE_REASONS).first }

        context "and the trigger is provider" do
          context "and the reason is a trainee reason" do
            before do
              subject.trigger = "provider"
              subject.reasons = [trainee_reason]
              subject.validate
            end

            it "is invalid" do
              expect(subject.errors[:reasons]).to contain_exactly(
                "Reasons selected are not valid for this trigger",
              )
            end
          end

          context "and the reason is a provider reason" do
            before do
              subject.trigger = "provider"
              subject.reasons = [provider_reason]
              subject.validate
            end

            it "is valid" do
              expect(subject.errors[:reasons]).to be_empty
            end
          end
        end

        context "and the trigger is trainee" do
          context "and the reason is a provider reason" do
            before do
              subject.trigger = "trainee"
              subject.reasons = [provider_reason]
              subject.validate
            end

            it "is invalid" do
              expect(subject.errors[:reasons]).to contain_exactly(
                "Reasons selected are not valid for this trigger",
              )
            end
          end

          context "and the reason is a trainee reason" do
            before do
              subject.trigger = "trainee"
              subject.reasons = [trainee_reason]
              subject.validate
            end

            it "is valid" do
              expect(subject.errors[:reasons]).to be_empty
            end
          end
        end
      end
    end
  end
end

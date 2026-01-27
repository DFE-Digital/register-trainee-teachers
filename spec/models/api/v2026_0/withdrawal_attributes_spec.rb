# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20260::WithdrawalAttributes do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:withdrawal_attributes) { described_class.new(trainee:) }
  let(:trainee_reason) { (WithdrawalReasons::TRAINEE_REASONS - WithdrawalReasons::PROVIDER_REASONS).first }
  let(:provider_reason) { (WithdrawalReasons::PROVIDER_REASONS - WithdrawalReasons::TRAINEE_REASONS).first }

  subject { withdrawal_attributes }

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:trigger).in_array(%w[provider trainee]).with_message("is not included in the list") }
    it { is_expected.to validate_inclusion_of(:future_interest).in_array(%w[yes no unknown]).with_message("is not included in the list") }

    context "withdrawal_date" do
      context "blank date" do
        before do
          subject.withdrawal_date = nil
          subject.validate
        end

        it "is blank" do
          expect(subject.errors[:withdrawal_date]).to contain_exactly(
            "Choose a withdrawal date",
          )
        end
      end

      context "invalid date" do
        before do
          subject.withdrawal_date = "14/11/23"
          subject.validate
        end

        it "is invalid" do
          expect(subject.errors[:withdrawal_date]).to contain_exactly(
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
            "Choose one or more reasons why the trainee withdrew from the course",
          )
        end
      end

      context "with trigger" do
        context "and the trigger is provider" do
          before do
            subject.trigger = "provider"
          end

          context "and the reason is a trainee reason" do
            before do
              subject.reasons = [trainee_reason]
            end

            it "is invalid" do
              subject.validate
              expect(subject.errors[:reasons]).to contain_exactly(
                "entered not valid for selected trigger eg unacceptable_behaviour for a trainee trigger",
              )
            end
          end

          context "and the reason is a provider reason" do
            before do
              subject.reasons = [provider_reason]
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:reasons]).to be_empty
            end
          end
        end

        context "and the trigger is trainee" do
          before do
            subject.trigger = "trainee"
          end

          context "and the reason is a provider reason" do
            before do
              subject.reasons = [provider_reason]
            end

            it "is invalid" do
              subject.validate
              expect(subject.errors[:reasons]).to contain_exactly(
                "entered not valid for selected trigger eg unacceptable_behaviour for a trainee trigger",
              )
            end
          end

          context "and the reason is a trainee reason" do
            before do
              subject.reasons = [trainee_reason]
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:reasons]).to be_empty
            end
          end
        end
      end

      describe "another reason" do
        context "and the trigger is trainee" do
          before do
            subject.trigger = "trainee"
            subject.reasons = [WithdrawalReasons::TRAINEE_CHOSE_TO_WITHDRAW_ANOTHER_REASON]
          end

          context "and the reason is not provided" do
            it "is invalid" do
              subject.validate
              expect(subject.errors[:another_reason]).to contain_exactly("Enter another reason")
            end
          end

          context "and the reason is provided" do
            before do
              subject.validate
              subject.another_reason = "Bespoke reason"
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:another_reason]).to be_empty
            end
          end
        end

        context "and the trigger is provider" do
          before do
            subject.trigger = "provider"
            subject.reasons = [WithdrawalReasons::HAD_TO_WITHDRAW_TRAINEE_ANOTHER_REASON]
          end

          context "and the another_reason text is not provided" do
            it "is invalid" do
              subject.validate
              expect(subject.errors[:another_reason]).to contain_exactly("Enter another reason")
            end
          end

          context "and the another_reason text is provided" do
            before do
              subject.another_reason = "Bespoke reason"
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:another_reason]).to be_empty
            end
          end
        end
      end

      describe "safeguarding concern" do
        context "and the trigger is trainee" do
          before do
            subject.trigger = "trainee"
            subject.reasons = [WithdrawalReasons::SAFEGUARDING_CONCERNS]
          end

          context "and the safeguarding_concern_reasons text is not provided" do
            it "is invalid" do
              subject.validate
              expect(subject.errors[:safeguarding_concern_reasons]).to contain_exactly("Enter the concerns")
            end
          end

          context "and the safeguarding_concern_reasons text is provided" do
            before do
              subject.validate
              subject.safeguarding_concern_reasons = "Some kind of reason"
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:safeguarding_concern_reasons]).to be_empty
            end
          end
        end

        context "and the trigger is provider" do
          before do
            subject.trigger = "provider"
            subject.reasons = [WithdrawalReasons::SAFEGUARDING_CONCERNS]
          end

          context "and the safeguarding_concern_reasons text is not provided" do
            it "is invalid" do
              subject.validate
              expect(subject.errors[:safeguarding_concern_reasons]).to contain_exactly("Enter the concerns")
            end
          end

          context "and the safeguarding_concern_reasons text is provided" do
            before do
              subject.safeguarding_concern_reasons = "Some sort of reason"
            end

            it "is valid" do
              subject.validate
              expect(subject.errors[:safeguarding_concern_reasons]).to be_empty
            end
          end
        end
      end
    end
  end
end

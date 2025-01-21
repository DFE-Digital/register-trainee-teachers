# frozen_string_literal: true

require "rails_helper"

describe Api::V01::WithdrawalAttributes do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:withdrawal_attributes) { described_class.new(trainee:) }

  subject { withdrawal_attributes }

  describe "validations" do
    it { is_expected.to validate_length_of(:withdraw_reasons_details).is_at_most(1000).with_message("Details about why the trainee withdrew must be 1000 characters or less") }
    it { is_expected.to validate_length_of(:withdraw_reasons_dfe_details).is_at_most(1000).with_message("What the Department for Education could have done must be 1000 characters or less") }
    it { is_expected.to validate_inclusion_of(:reasons).in_array(WithdrawalReasons::REASONS).with_message("Choose one or more reasons why the trainee withdrew from the course, or select \"Unknown\"") }

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

    context "unknown_exclusively" do
      before do
        another_reason = create(:withdrawal_reason, :another_reason)
        unknown = create(:withdrawal_reason, :unknown)
        subject.reasons = [another_reason.name, unknown.name]

        subject.validate
      end

      it "is blank" do
        expect(subject.errors[:reasons]).to contain_exactly(
          'Only select "Unknown" if no other withdrawal reasons apply',
        )
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Api::WithdrawalAttributes do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:withdrawal_attributes) { described_class.new(trainee:) }

  subject { withdrawal_attributes }

  describe "#save!" do
    subject {
      withdrawal_attributes.save!
    }

    context "invalid" do
      it "did not update traine" do
        expect {
          subject

          trainee.reload
        }.not_to change(trainee, :withdraw_date)
      end

      it "return false" do
        expect(subject).to be_falsey
      end

      it "did not call dqt withdraw service" do
        expect(Trainees::Withdraw).not_to receive(:call).with(trainee:)
        subject
      end
    end

    context "valid" do
      let(:unknown) { create(:withdrawal_reason, :unknown) }
      let(:attributes) {
        {
          reasons: [unknown.name],
          withdraw_date: Time.zone.now.to_s,
          withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
          withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
        }
      }

      before do
        withdrawal_attributes.assign_attributes(attributes)
      end

      it "has updated trainee" do
        expect {
          subject
          trainee.reload
        }.to change(trainee, :withdraw_date)
        .and change(trainee, :withdraw_reasons_details)
        .and change(trainee, :withdraw_reasons_dfe_details)
        .and change(trainee, :withdrawal_reasons)
        .and change(trainee, :state).from("trn_received").to("withdrawn")
      end

      it "call dqt withdraw service" do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).once
        subject
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_length_of(:withdraw_reasons_details).is_at_most(1000).with_message("Details about why the trainee withdrew must be 1000 characters or less") }
    it { is_expected.to validate_length_of(:withdraw_reasons_dfe_details).is_at_most(1000).with_message("What the Department for Education could have done must be 1000 characters or less") }

    it {
      expect(subject).to validate_presence_of(:reasons).with_message('Select why the trainee withdrew from the course or select "Unknown"')
    }

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
          subject.withdraw_date = "invalid"
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

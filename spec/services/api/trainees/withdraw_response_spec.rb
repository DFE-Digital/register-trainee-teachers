# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::WithdrawResponse do
  let(:version) { "v2025.0" }
  let(:withdraw_response) { described_class.call(trainee:, params:, version:) }
  let(:params) do
    {
      reasons:,
      withdraw_date:,
      trigger:,
      future_interest:,
      another_reason:,
      safeguarding_concern_reasons:,
    }
  end
  let(:reason) { create(:withdrawal_reason, :provider) }
  let(:reasons) { [reason.name] }
  let(:trigger) { "provider" }
  let(:future_interest) { "no" }
  let(:withdraw_date) { Time.zone.today.iso8601 }
  let(:another_reason) { "" }
  let(:safeguarding_concern_reasons) { "" }

  subject { withdraw_response }

  context "with a withdrawable trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received) }

    it "returns status ok with data" do
      expect(subject[:status]).to be(:ok)
      expect(subject[:json][:data]).to be_present
    end

    it "change the trainee" do
      expect {
        subject
      } .to change { trainee.reload.current_withdrawal&.trigger }.from(nil).to("provider")
      .and change { trainee.reload.current_withdrawal&.date&.iso8601 }.from(nil).to(withdraw_date)
      .and change { trainee.reload.current_withdrawal&.future_interest }.from(nil).to("no")
      .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
      .and change { trainee.reload.current_withdrawal_reasons&.pluck(:name) }.from(nil).to(reasons)
    end

    it "uses the trainee serializer" do
      expect(Api::V20250::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

      subject
    end

    context "with invalid params" do
      let(:trigger) { nil }
      let(:future_interest) { nil }
      let(:withdraw_date) { nil }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)

        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "withdraw_date Choose a withdrawal date" },
          { error: "UnprocessableEntity", message: "reasons entered not valid for selected trigger eg unacceptable_behaviour for a trainee trigger" },
          { error: "UnprocessableEntity", message: "trigger is not included in the list" },
          { error: "UnprocessableEntity", message: "future_interest is not included in the list" },
        )
      end

      it "did not change the trainee" do
        expect {
          subject
        }.not_to change(trainee, :withdraw_date)
      end

      context "with another reason selected but the another_reason text not provided" do
        let(:reason) { create(:withdrawal_reason, :another_reason) }

        it "returns status unprocessable entity with error response" do
          expect(subject[:status]).to be(:unprocessable_entity)
          expect(subject[:json][:errors]).to include(
            { error: "UnprocessableEntity", message: "another_reason Enter another reason" },
          )
        end
      end

      context "with safeguarding_concerns reason selected but the safeguarding_concern_reasons text not provided" do
        let(:reason) { create(:withdrawal_reason, :safeguarding) }

        it "returns status unprocessable entity with error response" do
          expect(subject[:status]).to be(:unprocessable_entity)
          expect(subject[:json][:errors]).to include(
            { error: "UnprocessableEntity", message: "safeguarding_concern_reasons Enter the concerns" },
          )
        end
      end
    end
  end

  context "with a non-withdrawable trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :itt_start_date_in_the_future) }

    it "returns status unprocessable entity with error response" do
      expect(subject[:status]).to be(:unprocessable_entity)
      expect(subject[:json][:errors]).to contain_exactly({ error: "StateTransitionError", message: "It’s not possible to perform this action while the trainee is in its current state" })
    end

    it "did not change the trainee" do
      expect {
        subject
      }.not_to change(trainee, :withdraw_date)
    end
  end
end

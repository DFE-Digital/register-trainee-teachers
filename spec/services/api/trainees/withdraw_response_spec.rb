# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::WithdrawResponse do
  let(:version) { "v0.1" }
  let(:withdraw_response) { described_class.call(trainee:, params:, version:) }
  let(:params) do
    {
      reasons:,
      withdraw_date:,
      trigger:,
      future_interest:,
    }
  end
  let(:reason) { create(:withdrawal_reason, :provider) }
  let(:reasons) { [reason.name] }
  let(:trigger) { "provider" }
  let(:future_interest) { "no" }
  let(:withdraw_date) { Time.zone.now.iso8601 }

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
      .and change { trainee.reload.withdraw_date }.from(nil)
      .and change { trainee.reload.current_withdrawal&.future_interest }.from(nil).to("no")
      .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
    end

    it "uses the trainee serializer" do
      expect(Api::V01::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

      subject
    end

    context "with invalid params" do
      let(:trigger) { nil }
      let(:future_interest) { nil }
      let(:withdraw_date) { nil }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "Withdraw date Choose a withdrawal date" },
          { error: "UnprocessableEntity", message: "Reasons Reasons selected are not valid for this trigger" },
          { error: "UnprocessableEntity", message: "Future interest is not included in the list" },
          { error: "UnprocessableEntity", message: "Trigger is not included in the list" },
        )
      end

      it "did not change the trainee" do
        expect {
          subject
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end

  context "with a non-withdrawable trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :itt_start_date_in_the_future) }

    it "returns status unprocessable entity with error response" do
      expect(subject[:status]).to be(:unprocessable_entity)
      expect(subject[:json][:errors]).to contain_exactly({ error: "StateTransitionError", message: "It's not possible to perform this action while the trainee is in its current state" })
    end

    it "did not change the trainee" do
      expect {
        subject
      }.not_to change(trainee, :withdraw_date)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Api::Trainees::WithdrawResponse do
  let(:version) { "v0.1" }
  let(:withdraw_response) { described_class.call(trainee:, params:, version:) }
  let(:params) do
    {
      reasons: [unknown.name],
      withdraw_date: Time.zone.now.iso8601,
      withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
      withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
    }
  end
  let(:unknown) { create(:withdrawal_reason, :unknown) }

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
      } .to change { trainee.reload.withdraw_reasons_details }.from(nil).to(params[:withdraw_reasons_details])
      .and change { trainee.reload.withdraw_date }.from(nil)
      .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
    end

    it "uses the trainee serializer" do
      expect(Api::V01::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

      subject
    end

    context "with invalid params" do
      let(:params) { { withdraw_reasons_details: nil, withdraw_date: nil } }

      it "returns status unprocessable entity with error response" do
        expect(subject[:status]).to be(:unprocessable_entity)
        expect(subject[:json][:errors]).to contain_exactly(
          { error: "UnprocessableEntity", message: "Withdraw date Choose a withdrawal date" },
          { error: "UnprocessableEntity", message: "Reasons Choose one or more reasons why the trainee withdrew from the course, or select \"Unknown\"" },
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
      expect(subject[:json][:errors]).to contain_exactly({ error: "StateTransitionError", message: "It’s not possible to perform this action while the trainee is in its current state" })
    end

    it "did not change the trainee" do
      expect {
        subject
      }.not_to change(trainee, :withdraw_date)
    end
  end
end

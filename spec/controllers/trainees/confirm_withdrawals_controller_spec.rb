# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmWithdrawalsController do
  include ActiveJob::TestHelper

  let(:current_user) { create(:user) }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#update" do
    it "it updates the placement assignment in DTTP to mark it as withdrawn" do
      expect {
        post :update, params: { trainee_id: trainee }
      }.to have_enqueued_job(WithdrawJob).with(trainee.id)
    end

    context "trainee state" do
      before do
        post :update, params: { trainee_id: trainee }
      end

      it "transitions the trainee state to withdrawn" do
        expect(trainee.reload).to be_withdrawn
      end
    end
  end
end

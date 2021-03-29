# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmDeferralsController do
  include ActiveJob::TestHelper

  let(:current_user) { create(:user) }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.provider) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(DeferralForm).to receive(:new).with(trainee).and_return(double(save!: true))
  end

  describe "#update" do
    it "it updates the placement assignment in DTTP to mark it as deferred" do
      expect {
        post :update, params: { trainee_id: trainee }
      }.to have_enqueued_job(DeferJob).with(trainee)
    end

    context "trainee state" do
      before do
        post :update, params: { trainee_id: trainee }
      end

      it "transitions the trainee state to deferred" do
        expect(trainee.reload).to be_deferred
      end
    end
  end
end

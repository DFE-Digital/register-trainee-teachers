# frozen_string_literal: true

require "rails_helper"

describe Trainees::ConfirmReinstatementsController do
  include ActiveJob::TestHelper

  let(:current_user) { build_current_user }
  let(:trainee) { create(:trainee, :deferred, trn: trn, provider: current_user.organisation) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "#update" do
    before do
      allow(ReinstatementForm).to receive(:new).with(trainee).and_return(double(save!: true, date: 1.day.ago))
      allow(IttEndDateForm).to receive(:new).with(trainee).and_return(double(save!: true))
    end

    context "with a trainee with a trn" do
      let(:trn) { "trn" }

      context "trainee has a trn" do
        it "updates the state of the trainee to trn_received" do
          expect {
            post :update, params: { trainee_id: trainee }
          }.to change {
            trainee.reload.state.to_sym
          }.from(:deferred).to(:trn_received)
        end
      end

      context "trainee doesn't have a trn" do
        let(:trn) { nil }

        it "updates the state of the trainee to submitted_for_trn" do
          post :update, params: { trainee_id: trainee }
          expect(trainee.reload.state).to eq("submitted_for_trn")
        end
      end
    end

    context "with a trainee with no trn" do
      let(:trn) { nil }

      it "transitions the trainee back to submitted_for_trn" do
        expect {
          post :update, params: { trainee_id: trainee }
          trainee.reload
        }.to change {
          trainee.state
        } .from("deferred") .to("submitted_for_trn")
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe TrnSubmissionsController do
  include ActiveJob::TestHelper

  describe "#create" do
    let(:current_user) { create(:user) }
    let(:trainee) { create(:trainee, :completed, provider: current_user.provider) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    context "when all sections are completed" do
      it "queues a background job to register trainee for TRN" do
        expect {
          post :create, params: { trainee_id: trainee }
        }.to have_enqueued_job(Dttp::RegisterForTrnJob).with(trainee, current_user.dttp_id)
      end

      it "queues a background job to poll for the trainee's TRN" do
        expect(Dttp::RetrieveTrnJob).to receive(:perform_with_default_delay).with(trainee)
        post :create, params: { trainee_id: trainee }
      end

      context "trainee state" do
        before do
          post :create, params: { trainee_id: trainee }
        end

        it "transitions the trainee state to submitted_for_trn" do
          expect(trainee.reload).to be_submitted_for_trn
        end
      end
    end
  end
end

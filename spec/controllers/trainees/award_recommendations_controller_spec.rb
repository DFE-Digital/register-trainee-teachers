# frozen_string_literal: true

require "rails_helper"

describe Trainees::AwardRecommendationsController do
  include ActiveJob::TestHelper

  let(:current_user) { build_current_user }
  let(:trainee) { create(:trainee, :trn_received, provider: current_user.organisation) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(OutcomeDateForm).to receive(:new).with(trainee, update_trs: false).and_return(double(save!: true))
  end

  describe "#create" do
    it "redirects user to the recommended page" do
      post :create, params: { trainee_id: trainee }
      expect(response).to redirect_to(recommended_trainee_outcome_details_path(trainee))
    end

    context "trainee state" do
      before do
        post :create, params: { trainee_id: trainee }
      end

      it "transitions the trainee state to recommended_for_award" do
        expect(trainee.reload).to be_recommended_for_award
      end
    end
  end

  context "when the TRS feature flag is enabled", feature_integrate_with_trs: true do
    describe "#create" do
      it "sends the ITT outcome to TRS" do
        expect {
          post :create, params: { trainee_id: trainee }
        }.to have_enqueued_job(Trs::UpdateProfessionalStatusJob).with(trainee)
      end
    end
  end
end

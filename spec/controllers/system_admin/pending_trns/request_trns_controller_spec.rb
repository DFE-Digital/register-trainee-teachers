# frozen_string_literal: true

require "rails_helper"

RSpec.describe SystemAdmin::PendingTrns::RequestTrnsController do
  let(:user) { build_current_user(user: create(:user, :system_admin)) }
  let(:trainee) { create(:trainee, :submitted_for_trn) }
  let(:request_id) { SecureRandom.uuid }
  let(:trn_request) { create(:dqt_trn_request, trainee: trainee, request_id: request_id) }

  before do
    allow(Trainee).to receive(:from_param).and_return(trainee)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "when TRS integration is enabled", feature_integrate_with_trs: true, feature_integrate_with_dqt: false do
      let(:trs_response) {
        {
          "requestId" => request_id,
          "status" => "Completed",
          "trn" => "1234567",
        }
      }

      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(trn_request)
        allow(trn_request).to receive(:destroy!)
        allow(trainee).to receive(:reload).and_return(trainee)
      end

      it "uses Trs::RegisterForTrnJob" do
        expect(Trs::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_return(
          OpenStruct.new(failed?: false),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:success]).to include("TRN requested successfully")
      end

      it "handles failure" do
        expect(Trs::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_return(
          OpenStruct.new(failed?: true),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:warning]).to include("TRN request failed")
      end

      it "handles API errors" do
        expect(Trs::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_raise(
          Trs::Client::HttpError.new("API error"),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:dqt_error]).to include("API error")
      end
    end

    context "when DQT integration is enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
      let(:dqt_response) {
        {
          "requestId" => request_id,
          "status" => "Completed",
          "trn" => "1234567",
        }
      }

      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(trn_request)
        allow(trn_request).to receive(:destroy!)
        allow(trainee).to receive(:reload).and_return(trainee)
      end

      it "uses Dqt::RegisterForTrnJob" do
        expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_return(
          OpenStruct.new(failed?: false),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:success]).to include("TRN requested successfully")
      end

      it "handles failure" do
        expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_return(
          OpenStruct.new(failed?: true),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:warning]).to include("TRN request failed")
      end

      it "handles API errors" do
        expect(Dqt::RegisterForTrnJob).to receive(:perform_now).with(trainee).and_raise(
          Dqt::Client::HttpError.new("API error"),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:dqt_error]).to include("API error")
      end
    end

    context "when neither integration is enabled", feature_integrate_with_dqt: false, feature_integrate_with_trs: false do
      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(trn_request)
        allow(trn_request).to receive(:destroy!)
        allow(trainee).to receive(:reload).and_return(trainee)
      end

      it "raises an error" do
        expect {
          patch :update, params: { id: trainee.slug }
        }.to raise_error(StandardError, "No integration is enabled")
      end
    end
  end
end 
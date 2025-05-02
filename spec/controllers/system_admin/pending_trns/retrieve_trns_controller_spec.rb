# frozen_string_literal: true

require "rails_helper"

RSpec.describe SystemAdmin::PendingTrns::RetrieveTrnsController do
  let(:user) { build_current_user(user: create(:user, :system_admin)) }
  let(:trainee) { create(:trainee, :submitted_for_trn) }
  let(:request_id) { SecureRandom.uuid }
  let(:trn) { "1234567" }
  let(:trn_request) { create(:dqt_trn_request, trainee: trainee, request_id: request_id) }

  before do
    allow(Trainee).to receive(:from_param).and_return(trainee)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "#update" do
    context "when TRS integration is enabled", feature_integrate_with_trs: true, feature_integrate_with_dqt: false do
      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(trn_request)
      end

      it "uses Trs::RetrieveTrn when TRN is available" do
        expect(Trs::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_return(trn)
        expect(trainee).to receive(:trn_received!).with(trn)
        expect(trn_request).to receive(:received!)

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:success]).to include("TRN successfully retrieved")
      end

      it "handles case when TRN is not available" do
        expect(Trs::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_return(nil)
        expect(trainee).not_to receive(:trn_received!)
        expect(trn_request).not_to receive(:received!)

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:warning]).to include("TRN still not available")
      end

      it "handles API errors" do
        expect(Trs::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_raise(
          Trs::Client::HttpError.new("API error"),
        )

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:dqt_error]).to include("API error")
      end
    end

    context "when DQT integration is enabled", feature_integrate_with_dqt: true, feature_integrate_with_trs: false do
      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(trn_request)
      end

      it "uses Dqt::RetrieveTrn when TRN is available" do
        expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_return(trn)
        expect(trainee).to receive(:trn_received!).with(trn)
        expect(trn_request).to receive(:received!)

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:success]).to include("TRN successfully retrieved")
      end

      it "handles case when TRN is not available" do
        expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_return(nil)
        expect(trainee).not_to receive(:trn_received!)
        expect(trn_request).not_to receive(:received!)

        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:warning]).to include("TRN still not available")
      end

      it "handles API errors" do
        expect(Dqt::RetrieveTrn).to receive(:call).with(trn_request: trn_request).and_raise(
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
      end

      it "raises an error" do
        expect {
          patch :update, params: { id: trainee.slug }
        }.to raise_error(StandardError, "No integration is enabled")
      end
    end

    context "when trainee has no TRN request" do
      before do
        allow(trainee).to receive(:dqt_trn_request).and_return(nil)
      end

      it "redirects with a warning" do
        patch :update, params: { id: trainee.slug }

        expect(response).to redirect_to(pending_trns_path)
        expect(flash[:warning]).to include("has no TRN request")
      end
    end
  end
end 
# frozen_string_literal: true

require "rails_helper"

describe "info endpoint" do
  context "with a valid authentication token" do
    context "non existant trainee" do
      let(:slug) { "non-existant" }

      it "returns status 404 with a valid JSON response" do
        post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body["error"]).to eq("Trainee not found")
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :trn_received) }
      let(:withdraw_params) do
        build(:trainee, :withdrawn_for_specific_reason)
          .attributes.symbolize_keys.slice(:withdraw_reasons_details, :withdraw_date)
      end
      let(:params) { withdraw_params }
      let(:slug) { trainee.slug }

      it "returns status 202 with a valid JSON response" do
        post("/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }, params: params)
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body["status"]).to eq("Trainee withdrawal request accepted")
      end

      it "change the trainee" do
        expect {
          post("/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }, params: params)
        } .to change { trainee.reload.withdraw_reasons_details }.from(nil).to(withdraw_params[:withdraw_reasons_details])
        .and change { trainee.reload.withdraw_date }.from(nil).to(withdraw_params[:withdraw_date])
        .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service" do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post("/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }, params: params)
      end

      context "with invalid params" do
        let(:params) { { withdraw_reasons_details: nil, withdraw_date: nil } }

        it "returns status 202 with a valid JSON response" do
          post("/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }, params: params)

          expect(response).to have_http_status(:accepted)
          expect(response.parsed_body["status"]).to eq("Trainee withdrawal request accepted")
        end

        it "did not change the trainee" do
          expect {
            post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
          }.not_to change(trainee, :withdraw_date)
        end
      end
    end

    context "with a non-withdrawable trainee" do
      let(:trainee) { create(:trainee, :itt_start_date_in_the_future) }
      let(:slug) { trainee.slug }

      it "returns status 202 with a valid JSON response" do
        post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body["status"]).to eq("Trainee withdrawal request accepted")
      end

      it "did not change the trainee" do
        expect {
          post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end
end

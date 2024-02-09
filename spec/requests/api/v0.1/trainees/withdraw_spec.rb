# frozen_string_literal: true

require "rails_helper"

describe "info endpoint" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:slug) { "non-existant" }

      it "returns status 404 with a valid JSON response" do
        # post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
        api_post(0.1, "/trainees/#{slug}/withdraw", token:)

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :trn_received, provider:) }
      let(:withdraw_params) do
        build(:trainee, :withdrawn_for_specific_reason)
          .attributes.symbolize_keys.slice(:withdraw_reasons_details, :withdraw_date)
      end
      let(:params) { withdraw_params }
      let(:slug) { trainee.slug }

      it "returns status 202 with a valid JSON response" do
        api_post(0.1, "/trainees/#{slug}/withdraw", token:, params:)
        expect(response).to have_http_status(:accepted)
        expect(response.parsed_body["data"]).to be_present
      end

      it "change the trainee" do
        expect {
          api_post(0.1, "/trainees/#{slug}/withdraw", token:, params:)
        } .to change { trainee.reload.withdraw_reasons_details }.from(nil).to(withdraw_params[:withdraw_reasons_details])
        .and change { trainee.reload.withdraw_date }.from(nil).to(withdraw_params[:withdraw_date])
        .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service" do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        api_post(0.1, "/trainees/#{slug}/withdraw", token:, params:)
      end

      it "uses the trainee serializer" do
        expect(TraineeSerializer).to receive(:new).with(trainee).and_return(trainee).at_least(:once)
        expect(trainee).to receive(:as_json).at_least(:once)

        api_post(0.1, "/trainees/#{slug}/withdraw", token:, params:)
      end

      context "with invalid params" do
        let(:params) { { withdraw_reasons_details: nil, withdraw_date: nil } }

        it "returns status 422 with a valid JSON response" do
          api_post(0.1, "/trainees/#{slug}/withdraw", token:, params:)

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body[:errors]).to contain_exactly({ error: "ParameterInvalid", message: "Please ensure valid values are provided for withdraw_reasons_details and withdraw_date" })
        end

        it "did not change the trainee" do
          expect {
            post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
          }.not_to change(trainee, :withdraw_date)
        end
      end
    end

    context "with a non-withdrawable trainee" do
      let(:trainee) { create(:trainee, :itt_start_date_in_the_future, provider:) }
      let(:slug) { trainee.slug }

      it "returns status 422 with a valid JSON response" do
        api_post(0.1, "/trainees/#{slug}/withdraw", token:)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "StateTransitionError", message: "It's not possible to perform this action while the trainee is in its current state" })
      end

      it "did not change the trainee" do
        expect {
          post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat" }
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end
end

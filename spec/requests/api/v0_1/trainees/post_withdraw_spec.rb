# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/withdraw` endpoint" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:slug) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received, provider:) }
      let(:reason) { create(:withdrawal_reason, :provider) }
      let(:params) do
        {
          data: {
            reasons: [reason.name],
            withdraw_date: Time.zone.now.iso8601,
            trigger: "provider",
            future_interest: "no",
          },
        }
      end
      let(:slug) { trainee.slug }

      it "returns status code 200 with a valid JSON response" do
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :trainee_id)).to eql(slug)
      end

      it "change the trainee" do
        expect {
          post(
            "/api/v0.1/trainees/#{slug}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        } .to change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service" do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "uses the trainee serializer" do
        expect(Api::V01::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      context "with invalid params" do
        let(:params) do
          {
            data:
              {
                withdraw_date: nil,
                reasons: [],
              },
          }
        end

        it "returns status code 422 with a valid JSON response" do
          post(
            "/api/v0.1/trainees/#{slug}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { error: "UnprocessableEntity", message: "Withdraw date Choose a withdrawal date" },
            { error: "UnprocessableEntity", message: "Reasons Choose one or more reasons why the trainee withdrew from the course" },
            { error: "UnprocessableEntity", message: "Future interest is not included in the list" },
            { error: "UnprocessableEntity", message: "Trigger is not included in the list" },
          )
        end

        it "did not change the trainee" do
          expect {
            post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
          }.not_to change(trainee, :withdraw_date)
        end
      end
    end

    context "with a non-withdrawable trainee" do
      let(:trainee) { create(:trainee, :itt_start_date_in_the_future, provider:) }
      let(:slug) { trainee.slug }
      let(:reason) { create(:withdrawal_reason, :provider) }
      let(:params) do
        {
          data: {
            reasons: [reason.name],
            withdraw_date: Time.zone.now.to_s,
            trigger: "provider",
            future_interest: "no",
          },
        }
      end

      it "returns status code 422 with a valid JSON response" do
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly({ "error" => "StateTransitionError", "message" => "It’s not possible to perform this action while the trainee is in its current state" })
      end

      it "did not change the trainee" do
        expect {
          post "/api/v0.1/trainees/#{slug}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end
end

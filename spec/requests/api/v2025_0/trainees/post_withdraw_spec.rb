# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/withdraw` endpoint" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:trainee_id) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        post(
          "/api/v2025.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received, provider:) }
      let(:reason) { create(:withdrawal_reason, :provider) }
      let(:withdraw_date) { Time.zone.today.iso8601 }
      let(:trigger) { "provider" }
      let(:future_interest) { "no" }
      let(:params) do
        {
          data: {
            reasons: [reason.name],
            withdraw_date: withdraw_date,
            trigger: trigger,
            future_interest: future_interest,
          },
        }
      end
      let(:trainee_id) { trainee.slug }

      it "returns status code 200 with a valid JSON response" do
        post(
          "/api/v2025.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :trainee_id)).to eql(trainee_id)
        expect(response.parsed_body.dig(:data, :withdraw_reasons)).to include(reason.name)
        expect(response.parsed_body.dig(:data, :withdraw_date)).to eq(withdraw_date)
        expect(response.parsed_body.dig(:data, :withdrawal_trigger)).to eq(trigger)
        expect(response.parsed_body.dig(:data, :withdrawal_future_interest)).to eq(future_interest)
      end

      it "change the trainee", openapi: false do
        expect {
          post(
            "/api/v2025.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        } .to change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service", openapi: false do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post(
          "/api/v2025.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "uses the trainee serializer", openapi: false do
        expect(Api::V20250::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

        post(
          "/api/v2025.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      context "with invalid params" do
        context "with empty withdraw_date" do
          let(:params) do
            super().deep_merge(
              data: {
                withdraw_date: nil,
              },
            )
          end

          it "returns status code 422 with a valid JSON response" do
            post(
              "/api/v2025.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdraw_date Choose a withdrawal date" },
            )
          end

          it "did not change the trainee" do
            expect {
              post "/api/v2025.0/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
            }.not_to change(trainee, :withdraw_date)
          end
        end

        context "with invalid withdraw_date" do
          let(:params) do
            super().deep_merge(
              data: {
                withdraw_date: trainee.itt_start_date - 1.day,
              },
            )
          end

          it "returns status code 422 with a valid JSON response" do
            post(
              "/api/v2025.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdraw_date must be after itt_start_date" },
            )
          end
        end

        context "with invalid reasons" do
          let(:params) do
            {
              data: {
                reasons: ["invalid_reason"],
              },
            }
          end

          it "returns status code 422 with a valid JSON response" do
            post(
              "/api/v2025.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdraw_date Choose a withdrawal date" },
              { error: "UnprocessableEntity", message: "reasons entered not valid for selected trigger eg unacceptable_behaviour for a trainee trigger" },
              { error: "UnprocessableEntity", message: "future_interest is not included in the list" },
              { error: "UnprocessableEntity", message: "trigger is not included in the list" },
            )
          end
        end
      end
    end

    context "with a non-withdrawable trainee" do
      let(:trainee) { create(:trainee, :itt_start_date_in_the_future, provider:) }
      let(:trainee_id) { trainee.slug }
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
          "/api/v2025.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly({ "error" => "StateTransitionError", "message" => "It’s not possible to perform this action while the trainee is in its current state" })
      end

      it "did not change the trainee" do
        expect {
          post "/api/v2025.0/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end
end

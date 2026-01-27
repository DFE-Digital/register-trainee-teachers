# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/withdraw` endpoint" do
  context "with a valid authentication token" do
    let!(:auth_token) { create(:authentication_token) }
    let!(:token) { auth_token.token }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:trainee_id) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received, provider:) }
      let(:reason) { create(:withdrawal_reason, :provider) }
      let(:withdrawal_date) { Time.zone.today.iso8601 }
      let(:trigger) { "provider" }
      let(:future_interest) { "no" }
      let(:params) do
        {
          data: {
            reasons: [reason.name],
            withdrawal_date: withdrawal_date,
            trigger: trigger,
            future_interest: future_interest,
          },
        }
      end
      let(:trainee_id) { trainee.slug }

      it "returns status code 200 with a valid JSON response" do
        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :trainee_id)).to eql(trainee_id)
        expect(response.parsed_body.dig(:data, :withdrawal_reasons)).to include(reason.name)
        expect(response.parsed_body.dig(:data, :withdrawal_date)).to eq(withdrawal_date)
        expect(response.parsed_body.dig(:data, :withdrawal_trigger)).to eq(trigger)
        expect(response.parsed_body.dig(:data, :withdrawal_future_interest)).to eq(future_interest)
      end

      it "change the trainee", openapi: false do
        expect {
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        } .to change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the trs withdraw service", openapi: false do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "uses the trainee serializer", openapi: false do
        expect(Api::V20260::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "returns the trainee's withdrawal details in the response" do
        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )

        expect(response.parsed_body.dig(:data, :withdrawal_reasons)).to contain_exactly(reason.name)
        expect(response.parsed_body.dig(:data, :withdrawal_date)).to eq(withdrawal_date)
        expect(response.parsed_body.dig(:data, :withdrawal_trigger)).to eq(trigger)
        expect(response.parsed_body.dig(:data, :withdrawal_future_interest)).to eq(future_interest)
        expect(response.parsed_body.dig(:data, :withdrawal_another_reason)).to be_nil
        expect(response.parsed_body.dig(:data, :withdrawal_safeguarding_concern_reaasons)).to be_nil
      end

      context "with `another_reason`" do
        let(:reason) { create(:withdrawal_reason, :provider, name: WithdrawalReasons::HAD_TO_WITHDRAW_TRAINEE_ANOTHER_REASON) }

        it "returns status code 422 with a valid JSON response when the `another_reason` is blank" do
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { error: "UnprocessableEntity", message: "another_reason Enter another reason" },
          )
        end

        it "returns status code 200 with a valid JSON response when the `another_reason` is present" do
          params[:data][:another_reason] = "Some other reason"
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:success)
          expect(response.parsed_body[:errors]).to be_nil
        end

        it "returns the trainee's withdrawal details in the response" do
          params[:data][:another_reason] = "Another test reason"
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response.parsed_body.dig(:data, :withdrawal_reasons)).to contain_exactly(reason.name)
          expect(response.parsed_body.dig(:data, :withdrawal_date)).to eq(withdrawal_date)
          expect(response.parsed_body.dig(:data, :withdrawal_trigger)).to eq(trigger)
          expect(response.parsed_body.dig(:data, :withdrawal_future_interest)).to eq(future_interest)
          expect(response.parsed_body.dig(:data, :withdrawal_another_reason)).to eq("Another test reason")
          expect(response.parsed_body.dig(:data, :withdrawal_safeguarding_concern_reaasons)).to be_nil
        end
      end

      context "with `safeguarding_concerns`" do
        let(:reason) { create(:withdrawal_reason, :provider, name: WithdrawalReasons::SAFEGUARDING_CONCERNS) }

        it "returns status code 422 with a valid JSON response when the `safeguarding_concern_reasons` is blank" do
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { error: "UnprocessableEntity", message: "safeguarding_concern_reasons Enter the concerns" },
          )
        end

        it "returns status code 200 with a valid JSON response when the `safeguarding_concern_reasons` is present" do
          params[:data][:safeguarding_concern_reasons] = "Some safeguarding reasons"
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:success)
          expect(response.parsed_body[:errors]).to be_nil
        end

        it "returns the trainee's withdrawal details in the response" do
          params[:data][:safeguarding_concern_reasons] = "Some safeguarding reasons"
          post(
            "/api/v2026.0/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response.parsed_body.dig(:data, :withdrawal_reasons)).to contain_exactly(reason.name)
          expect(response.parsed_body.dig(:data, :withdrawal_date)).to eq(withdrawal_date)
          expect(response.parsed_body.dig(:data, :withdrawal_trigger)).to eq(trigger)
          expect(response.parsed_body.dig(:data, :withdrawal_future_interest)).to eq(future_interest)
          expect(response.parsed_body.dig(:data, :withdrawal_another_reason)).to be_nil
          expect(response.parsed_body.dig(:data, :withdrawal_safeguarding_concern_reasons)).to eq("Some safeguarding reasons")
        end
      end

      context "with invalid params" do
        context "with empty withdrawal_date" do
          let(:params) do
            super().deep_merge(
              data: {
                withdrawal_date: nil,
              },
            )
          end

          it "returns status code 422 with a valid JSON response" do
            post(
              "/api/v2026.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdrawal_date Choose a withdrawal date" },
            )
          end

          it "did not change the trainee" do
            expect {
              post "/api/v2026.0/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
            }.not_to change { trainee.reload.current_withdrawal&.date }
          end
        end

        context "with invalid withdrawal_date" do
          let(:params) do
            super().deep_merge(
              data: {
                withdrawal_date: trainee.itt_start_date - 1.day,
              },
            )
          end

          it "returns status code 422 with a valid JSON response" do
            post(
              "/api/v2026.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdrawal_date must be after itt_start_date" },
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
              "/api/v2026.0/trainees/#{trainee_id}/withdraw",
              headers: { Authorization: "Bearer #{token}", **json_headers },
              params: params.to_json,
            )

            expect(response).to have_http_status(:unprocessable_entity)

            expect(response.parsed_body[:errors]).to contain_exactly(
              { error: "UnprocessableEntity", message: "withdrawal_date Choose a withdrawal date" },
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
            withdrawal_date: Time.zone.now.to_s,
            trigger: "provider",
            future_interest: "no",
          },
        }
      end

      it "returns status code 422 with a valid JSON response" do
        post(
          "/api/v2026.0/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly({ "error" => "StateTransitionError", "message" => "It’s not possible to perform this action while the trainee is in its current state" })
      end

      it "did not change the trainee" do
        expect {
          post "/api/v2026.0/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
        }.not_to change { trainee.reload.current_withdrawal&.date }
      end
    end
  end
end

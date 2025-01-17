# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/withdraw` endpoint", skip: "api endpoint has been disabled" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:trainee_id) { "non-existant" }

      it "returns status code 404 with a valid JSON response" do
        post(
          "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received, provider:) }
      let(:unknown) { create(:withdrawal_reason, :unknown) }
      let(:params) do
        {
          data: {
            reasons: [unknown.name],
            withdraw_date: Time.zone.now.to_s,
            withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
            withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
          },
        }
      end
      let(:trainee_id) { trainee.slug }

      it "returns status code 200 with a valid JSON response" do
        post(
          "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :trainee_id)).to eql(trainee_id)
      end

      it "change the trainee", openapi: false do
        expect {
          post(
            "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )
        } .to change { trainee.reload.withdraw_reasons_details }.from(nil).to(params[:data][:withdraw_reasons_details])
        .and change { trainee.reload.withdraw_date }.from(nil)
        .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service", openapi: false do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post(
          "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      it "uses the trainee serializer", openapi: false do
        expect(Api::V10Pre::TraineeSerializer).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

        post(
          "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
      end

      context "with invalid params" do
        let(:params) do
          {
            data:
              {
                withdraw_reasons_details: nil,
                withdraw_date: nil,
              },
          }
        end

        it "returns status code 422 with a valid JSON response" do
          post(
            "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
            headers: { Authorization: "Bearer #{token}", **json_headers },
            params: params.to_json,
          )

          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { error: "UnprocessableEntity", message: "Withdraw date Choose a withdrawal date" },
            { error: "UnprocessableEntity", message: "Reasons Choose one or more reasons why the trainee withdrew from the course, or select \"Unknown\"" },
          )
        end

        it "did not change the trainee" do
          expect {
            post "/api/v1.0-pre/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
          }.not_to change(trainee, :withdraw_date)
        end
      end
    end

    context "with a non-withdrawable trainee" do
      let(:trainee) { create(:trainee, :itt_start_date_in_the_future, provider:) }
      let(:trainee_id) { trainee.slug }
      let(:unknown) { create(:withdrawal_reason, :unknown) }
      let(:params) do
        {
          data: {
            reasons: [unknown.name],
            withdraw_date: Time.zone.now.to_s,
            withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
            withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
          },
        }
      end

      it "returns status code 422 with a valid JSON response" do
        post(
          "/api/v1.0-pre/trainees/#{trainee_id}/withdraw",
          headers: { Authorization: "Bearer #{token}", **json_headers },
          params: params.to_json,
        )
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "StateTransitionError", message: "It's not possible to perform this action while the trainee is in its current state" })
      end

      it "did not change the trainee" do
        expect {
          post "/api/v1.0-pre/trainees/#{trainee_id}/withdraw", headers: { Authorization: "Bearer bat", **json_headers }
        }.not_to change(trainee, :withdraw_date)
      end
    end
  end
end

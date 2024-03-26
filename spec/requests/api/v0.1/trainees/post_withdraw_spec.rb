# frozen_string_literal: true

require "rails_helper"

describe "`POST /trainees/:trainee_id/withdraw` endpoint" do
  context "with a valid authentication token" do
    let(:token) { "trainee_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
    let!(:provider) { auth_token.provider }

    context "non existant trainee" do
      let(:slug) { "non-existant" }

      it "returns status 404 with a valid JSON response" do
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}" },
        )

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly({ error: "NotFound", message: "Trainee(s) not found" })
      end
    end

    context "with a withdrawable trainee" do
      let(:trainee) { create(:trainee, :trn_received, provider:) }
      let(:unknown) { create(:withdrawal_reason, :unknown) }
      let(:params) do
        {
          reasons: [unknown.name],
          withdraw_date: Time.zone.now.to_s,
          withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
          withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
        }
      end
      let(:slug) { trainee.slug }

      it "returns status 200 with a valid JSON response" do
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}" },
          params: params,
        )
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body.dig(:data, :trainee_id)).to eql(slug)
      end

      it "change the trainee" do
        expect {
          post(
            "/api/v0.1/trainees/#{slug}/withdraw",
            headers: { Authorization: "Bearer #{token}" },
            params: params,
          )
        } .to change { trainee.reload.withdraw_reasons_details }.from(nil).to(params[:withdraw_reasons_details])
        .and change { trainee.reload.withdraw_date }.from(nil)
        .and change { trainee.reload.state }.from("trn_received").to("withdrawn")
      end

      it "calls the dqt withdraw service" do
        expect(Trainees::Withdraw).to receive(:call).with(trainee:).at_least(:once)

        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}" },
          params: params,
        )
      end

      it "uses the trainee serializer" do
        expect(TraineeSerializer::V01).to receive(:new).with(trainee).and_return(double(as_hash: trainee.attributes)).at_least(:once)

        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}" },
          params: params,
        )
      end

      context "with invalid params" do
        let(:params) { { withdraw_reasons_details: nil, withdraw_date: nil } }

        it "returns status 422 with a valid JSON response" do
          post(
            "/api/v0.1/trainees/#{slug}/withdraw",
            headers: { Authorization: "Bearer #{token}" },
            params: params,
          )

          expect(response).to have_http_status(:unprocessable_entity)

          expect(response.parsed_body[:errors]).to contain_exactly(
            { error: "UnprocessableEntity", message: "Withdraw date Choose a withdrawal date" },
            { error: "UnprocessableEntity", message: "Reasons Select why the trainee withdrew from the course or select \"Unknown\"" },
          )
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
        post(
          "/api/v0.1/trainees/#{slug}/withdraw",
          headers: { Authorization: "Bearer #{token}" },
        )
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

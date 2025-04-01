# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /trainees/{trainee_id}/defer" do
  let!(:token) { AuthenticationToken.create_with_random_token(provider: trainee.provider, created_by: trainee.provider.users.first, name: "test token").token }

  let(:defer_date) { Time.zone.today.iso8601 }

  describe "success" do
    let(:trainee) do
      create(:trainee, :trn_received)
    end

    it "defers a trainee" do
      post "/api/v1.0-pre/trainees/#{trainee.slug}/defer",
           headers: { authorization: "Bearer #{token}" },
           params: { data: { defer_date: } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).not_to have_key(:errors)
      expect(response.parsed_body[:data][:defer_date]).to eq(defer_date)
    end
  end

  describe "failure" do
    let(:trainee) { create(:trainee, :trn_received) }

    context "when the trainee cannot be found" do
      let(:another_trainee) { create(:trainee) }

      it "returns status code 404" do
        post "/api/v1.0-pre/trainees/#{another_trainee.slug}/defer",
             headers: { authorization: "Bearer #{token}" },
             params: { data: { defer_date: } }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly(
          "error" => "NotFound",
          "message" => "Trainee(s) not found",
        )
      end
    end

    it "does not defer the trainee" do
      post "/api/v1.0-pre/trainees/#{trainee.slug}/defer",
           headers: { authorization: "Bearer #{token}" },
           params: { data: { defer_date: nil } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body[:errors]).not_to be_empty
      expect(response.parsed_body[:errors]).to contain_exactly(
        {
          "error" => "UnprocessableEntity",
          "message" => "Defer date can't be blank",
        },
      )

      expect(trainee.deferred?).to be(false)
    end
  end
end

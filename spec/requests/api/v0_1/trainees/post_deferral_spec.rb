# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /trainees/{trainee_id}/defer" do
  let!(:token) { AuthenticationToken.create_with_random_token(provider: trainee.provider) }

  let(:current_date) { Time.zone.today.iso8601 }

  before do
    Timecop.freeze(current_date)
  end

  after do
    Timecop.return
  end

  describe "success" do
    context "when a defer date is required" do
      let(:trainee) do
        create(:trainee, :trn_received)
      end

      it "defers a trainee" do
        post "/api/v0.1/trainees/#{trainee.slug}/defer",
             headers: { authorization: "Bearer #{token}" },
             params: { defer_date: Time.zone.today.iso8601 }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to have_key(:errors)
        expect(response.parsed_body[:data][:defer_date]).to eq(current_date)
      end
    end

    context "when a defer date is not required" do
      let(:trainee) do
        create(:trainee, :trn_received, :itt_start_date_in_the_future)
      end

      it "defers a trainee" do
        post "/api/v0.1/trainees/#{trainee.slug}/defer",
             headers: { authorization: "Bearer #{token}" }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).not_to have_key(:errors)
        expect(response.parsed_body[:data][:defer_date]).to be_nil
      end
    end
  end

  describe "failure" do
    let(:trainee) { create(:trainee, :trn_received) }

    context "when the trainee cannot be found" do
      let(:another_trainee) { create(:trainee) }

      it "returns 404" do
        post "/api/v0.1/trainees/#{another_trainee.slug}/defer",
             headers: { authorization: "Bearer #{token}" }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    it "does not defer the trainee" do
      post "/api/v0.1/trainees/#{trainee.slug}/defer",
           headers: { authorization: "Bearer #{token}" }, as: :json

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
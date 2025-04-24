# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v1.0-rc/trainees/:trainee_id/recommend-for-qts" do
  let(:token) { AuthenticationToken.create_with_random_token(provider: trainee.provider, created_by: trainee.provider.users.first, name: "test token").token }

  let(:trainee) do
    create(
      :trainee,
      :trn_received,
    )
  end

  describe "success" do
    let(:current_time) { Time.zone.now }

    before do
      Timecop.freeze(current_time)
    end

    after do
      Timecop.return
    end

    it "recommends the trainee for a qts award" do
      post "/api/v1.0-rc/trainees/#{trainee.slug}/recommend-for-qts",
           headers: { authorization: "Bearer #{token}" },
           params: { data: { qts_standards_met_date: Time.zone.today } }, as: :json

      expect(response).to have_http_status(:accepted)
      expect(response.parsed_body[:data][:recommended_for_award_at]).to eq(current_time.iso8601)
      expect(response.parsed_body).not_to have_key(:errors)
    end
  end

  describe "failure" do
    context "when the trainee cannot be found" do
      let(:other_trainee) { create(:trainee, :trn_received) }

      it "returns status code 404" do
        post "/api/v1.0-rc/trainees/#{other_trainee.slug}/recommend-for-qts",
             headers: { authorization: "Bearer #{token}" },
             params: { data: { qts_standards_met_date: Time.zone.today } }, as: :json

        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body[:errors]).to contain_exactly(
          "error" => "NotFound",
          "message" => "Trainee(s) not found",
        )
      end
    end

    context "when the trainee has no degree information" do
      let(:trainee) do
        create(
          :trainee,
          :without_degrees,
          :trn_received,
        )
      end

      it "does not recommend the trainee for a qts award" do
        post "/api/v1.0-rc/trainees/#{trainee.slug}/recommend-for-qts",
             headers: { authorization: "Bearer #{token}" },
             params: { data: { qts_standards_met_date: Time.zone.today } }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(trainee.recommended_for_award_at).to be_nil
        expect(trainee.recommended_for_award?).to be(false)

        expect(response.parsed_body[:errors]).to contain_exactly(
          "error" => "UnprocessableEntity",
          "message" => "Trainee degree information must be completed before QTS recommendation",
        )
      end
    end

    it "does not recommend the trainee for a qts award" do
      post "/api/v1.0-rc/trainees/#{trainee.slug}/recommend-for-qts",
           headers: { authorization: "Bearer #{token}" },
           params: { data: { qts_standards_met_date: nil } }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(trainee.recommended_for_award_at).to be_nil
      expect(trainee.recommended_for_award?).to be(false)

      expect(response.parsed_body[:errors]).to contain_exactly(
        "error" => "UnprocessableEntity",
        "message" => "QTS standards met date can't be blank",
      )
    end
  end
end

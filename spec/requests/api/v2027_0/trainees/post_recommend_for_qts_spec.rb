# frozen_string_literal: true

require "rails_helper"

RSpec.describe "POST /api/v2027.0/trainees/:trainee_id/recommend-for-qts", openapi: false do
  let(:token) { create(:authentication_token, provider: trainee.provider).token }

  let(:trainee) do
    create(
      :trainee,
      :trn_received,
      :with_employing_school,
    )
  end

  it "returns status code 404" do
    post "/api/v2027.0/trainees/#{trainee.slug}/recommend-for-qts",
         headers: { authorization: "Bearer #{token}" },
         params: { data: { qts_or_eyts_requirements_met_date: Time.zone.today } }, as: :json

    expect(response).to have_http_status(:not_found)
  end
end

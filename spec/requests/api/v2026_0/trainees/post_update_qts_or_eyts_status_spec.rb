# frozen_string_literal: true

require "rails_helper"

# Route alias — full coverage in post_recommend_for_qts_spec.rb
RSpec.describe "POST /api/v2026.0/trainees/:trainee_id/update-qts-or-eyts-status" do
  let(:token) { create(:authentication_token, provider: trainee.provider).token }

  let(:trainee) do
    create(
      :trainee,
      :trn_received,
    )
  end

  let(:current_time) { Time.zone.now }

  before { Timecop.freeze(current_time) }
  after { Timecop.return }

  it "works the same as the old recommend-for-qts endpoint" do
    post "/api/v2026.0/trainees/#{trainee.slug}/update-qts-or-eyts-status",
         headers: { authorization: "Bearer #{token}" },
         params: { data: { qts_standards_met_date: Time.zone.today } }, as: :json

    expect(response).to have_http_status(:accepted)
    expect(response.parsed_body[:data][:recommended_for_award_at]).to eq(current_time.iso8601)
  end
end

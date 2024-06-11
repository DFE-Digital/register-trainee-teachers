# frozen_string_literal: true

require "rails_helper"

describe "audit trail attribution" do
  let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :trn_received) }
  let(:provider) { trainee.provider }

  context "with a valid authentication token and the feature flag on" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:unknown) { create(:withdrawal_reason, :unknown) }
    let(:params) do
      {
        reasons: [unknown.name],
        withdraw_date: Time.zone.now.to_s,
        withdraw_reasons_details: Faker::JapaneseMedia::CowboyBebop.quote,
        withdraw_reasons_dfe_details: Faker::JapaneseMedia::StudioGhibli.quote,
      }
    end

    it "returns status 200 with a valid JSON response" do
      post(
        "/api/v1.0/trainees/#{trainee.slug}/withdraw",
        headers: { Authorization: "Bearer #{token}", **json_headers },
        params: params.to_json,
      )
      expect(response).to have_http_status(:ok)

      last_audit_entry = trainee.reload.audits.last
      expect(last_audit_entry.user).to eq(provider)
    end
  end
end

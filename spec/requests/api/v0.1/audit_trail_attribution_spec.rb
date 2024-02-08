# frozen_string_literal: true

require "rails_helper"

describe "audit trail attribution" do
  let(:trainee) { create(:trainee, :trn_received) }
  let(:provider) { trainee.provider }

  context "with a valid authentication token and the feature flag on" do
    let(:token) { AuthenticationToken.create_with_random_token(provider:) }
    let(:params) do
      build(:trainee, :withdrawn_for_specific_reason)
        .attributes.symbolize_keys.slice(:withdraw_reasons_details, :withdraw_date)
    end

    it "returns status 200 with a valid JSON response" do
      post(
        "/api/v0.1/trainees/#{trainee.slug}/withdraw",
        headers: { Authorization: "Bearer #{token}" },
        params: params,
      )
      expect(response).to have_http_status(:accepted)

      last_audit_entry = trainee.reload.audits.last
      expect(last_audit_entry.user).to eq(provider)
    end
  end
end

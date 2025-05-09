# frozen_string_literal: true

require "rails_helper"

describe "`DELETE /trainees/:trainee_slug/degrees/:slug` endpoint" do
  context "with a valid authentication token and the feature flag on" do
    let(:provider) { trainee.provider }
    let(:token) { AuthenticationToken.create_with_random_token(provider: provider, name: "test token", created_by: provider.users.first).token }
    let(:auth_token) do
      create(
        :authentication_token,
        hashed_token: AuthenticationToken.hash_token(token),
      )
    end
    let(:trainee) { create(:trainee) }
    let!(:degree) do
      create(
        :degree,
        :uk_degree_with_details,
        trainee:,
      )
    end

    context "with a valid trainee and degree" do
      it "deletes the degree and returns a 200 status (ok)" do
        delete(
          "/api/v2025.0-rc/trainees/#{trainee.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )
        expect(response.parsed_body["data"]).to be_present
        expect(trainee.reload.degrees.count).to be_zero
        expect(response.parsed_body.dig(*%w[data trainee_id])).to eq(trainee.slug)
        expect(response.parsed_body.dig(*%w[data first_names])).to eq(trainee.first_names)
        expect(response.parsed_body.dig(*%w[data last_name])).to eq(trainee.last_name)
      end
    end

    context "with an invalid trainee" do
      let(:trainee_for_another_provider) { create(:trainee) }

      it "does not delete the degree and returns a 404 status (not_found)" do
        delete(
          "/api/v2025.0-rc/trainees/#{trainee_for_another_provider.slug}/degrees/#{degree.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(1)
      end
    end

    context "with an invalid degree" do
      let(:degree_for_another_trainee) { create(:degree) }

      it "does not delete the degree and returns a 404 status (not_found)" do
        delete(
          "/api/v2025.0-rc/trainees/#{trainee.slug}/degrees/#{degree_for_another_trainee.slug}",
          headers: { Authorization: "Bearer #{token}", **json_headers },
        )
        expect(response).to have_http_status(:not_found)
        expect(trainee.reload.degrees.count).to eq(1)
      end
    end
  end
end

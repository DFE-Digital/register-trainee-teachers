# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "register versioned api GET request" do |version, path, completed|
  url = path.gsub(":api_version", version)

  describe "`GET #{url}` endpoint" do
    let(:auth_token) { create(:authentication_token) }
    let(:token) { auth_token.token }

    let(:trainee_with_slug_placements_and_degrees) do
      create(:trainee,
             :trn_received,
             provider: auth_token.provider,
             slug: ":trainee_slug",
             placements: [build(:placement, slug: ":placement_slug")],
             degrees: [build(:degree, slug: ":degree_slug")])
    end

    let(:trainee_with_slug) { create(:trainee, :trn_received, provider: auth_token.provider, slug: ":slug") }

    let(:academic_cycle) { create(:academic_cycle, :current) }

    before do
      academic_cycle
      trainee_with_slug
      trainee_with_slug_placements_and_degrees
      get url, headers: { Authorization: token }
    end

    if completed
      it "has http status ok" do
        expect(response).to have_http_status(:ok)
      end
    else
      it "has http status bad request with error message" do
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eql({ "errors" => ["Version '#{version}' not available"] })
      end
    end
  end
end

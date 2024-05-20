# frozen_string_literal: true

require "rails_helper"

paths_to_exclude = ["/api-docs/:api_version/openapi", "/api-docs/:api_version/reference", "/api/:api_version/info"]
paths = Rails.application.routes.routes.select { |route| route.verb == "GET" && route.parts.include?(:api_version) }
  .map { |route| route.path.spec.to_s.gsub("(.:format)", "") }
  .select { |path| paths_to_exclude.exclude?(path) }
  .map { |path| path.gsub(":api_version", "v1.0") }

paths.each do |url|
  describe "`GET #{url}` endpoint" do
    let(:token) { "info_token" }
    let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }

    let(:trainee_with_trainee_slug) do
      create(:trainee,
             :trn_received,
             provider: auth_token.provider,
             slug: ":trainee_slug",
             placements: [build(:placement, slug: ":slug")],
             degrees: [build(:degree, slug: ":slug")])
    end

    let(:trainee_with_slug) { create(:trainee, :trn_received, provider: auth_token.provider, slug: ":slug") }

    let(:academic_cycle) { create(:academic_cycle, :current) }

    before do
      academic_cycle
      trainee_with_slug
      trainee_with_trainee_slug
      get url, headers: { Authorization: token }
    end

    it "has http status bad request with error message" do
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eql({ "errors" => ["Version 'v1.0' not available"] })
    end
  end
end

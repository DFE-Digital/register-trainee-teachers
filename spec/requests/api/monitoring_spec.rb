# frozen_string_literal: true

require "rails_helper"

describe "API Monitoring" do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:trainee) { create(:trainee, :with_hesa_trainee_detail, slug: "12345", provider: auth_token.provider) }
  let(:metrics) { Yabeda::CollectorsRegistry.all }
  let(:response) do
    get(
      "/api/v2025.0-rc/trainees/#{trainee.slug}",
      headers: { Authorization: "Bearer #{token}" },
    )
  end

  it "measures response size for every request" do
    expect(Yabeda.register_api.response_size).to receive(:measure)
    response
  end

  it "increments unsuccessful_requests_total for failed request" do
    controller = Api::TraineesController.new
    allow(Api::TraineesController).to receive(:new).and_return(controller)
    allow(controller).to receive(:show).and_raise(StandardError)

    expect(Yabeda.register_api.unsuccessful_requests_total).to receive(:increment)
    expect { response }.to raise_error(StandardError)
  end
end

require 'rails_helper'

describe 'API Monitoring', type: :request do
  let(:token) { "trainee_token" }
  let!(:auth_token) { create(:authentication_token, hashed_token: AuthenticationToken.hash_token(token)) }
  let!(:trainee) { create(:trainee, :with_hesa_trainee_detail, slug: "12345", provider: auth_token.provider) }
  let(:metrics) { Yabeda::CollectorsRegistry.all }
  let(:response) do
    get(
      "/api/v1.0/trainees/#{trainee.slug}",
      headers: { Authorization: "Bearer #{token}" },
    )
  end

  it 'increments request_total and measures request_duration for successful request' do
    expect(Yabeda.register_api.requests_total).to receive(:increment)
    expect(Yabeda.register_api.request_duration).to receive(:measure)
    response
  end

  it 'measures response size for every request' do
    expect(Yabeda.register_api.response_size).to receive(:measure)
    response
  end

  it 'increments unsuccessful_requests_total for failed request' do
    allow_any_instance_of(Api::TraineesController).to receive(:show).and_raise(StandardError)
    expect(Yabeda.register_api.unsuccessful_requests_total).to receive(:increment)
    expect { response }.to raise_error(StandardError)
  end
end

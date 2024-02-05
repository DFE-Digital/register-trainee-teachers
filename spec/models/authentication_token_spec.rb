# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationToken, type: :model do
  let(:plain_token) { "plain_token" }
  let(:hashed_token) { Digest::SHA256.hexdigest(plain_token) }
  let(:provider) { create(:provider) }

  it "hashes the token before saving" do
    token = AuthenticationToken.new(hashed_token: plain_token, provider: provider)
    token.save
    expect(token.hashed_token).to eq(hashed_token)
  end

  it "can find a record using the authenticate method" do
    token = AuthenticationToken.create!(hashed_token: plain_token, provider: provider)
    expect(AuthenticationToken.authenticate(plain_token)).to eq(token)
  end

  it "does not hash the token if the hashed_token has not changed" do
    token = AuthenticationToken.create!(hashed_token: plain_token, provider: provider)
    original_hashed_token = token.hashed_token
    token.save
    expect(token.hashed_token).to eq(original_hashed_token)
  end
end

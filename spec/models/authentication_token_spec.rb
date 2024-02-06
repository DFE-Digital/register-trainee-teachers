# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationToken do
  let(:provider) { create(:provider) }

  describe '.create_with_random_token' do
    subject(:authentication_token) { described_class.create_with_random_token(provider_id: provider.id) }

    it 'creates a new AuthenticationToken' do
      expect(authentication_token).to be_persisted
    end

    it 'sets the hashed_token' do
      expect(authentication_token.hashed_token).not_to be_nil
    end

    it 'sets the provider_id' do
      expect(authentication_token.provider_id).to eq(provider.id)
    end

    it { is_expected.to validate_uniqueness_of(:hashed_token) }

    it { is_expected.to belong_to(:provider) }
  end
end

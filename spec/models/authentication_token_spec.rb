# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationToken do
  let(:user) { create(:user, :hei) }
  let(:provider) { user.providers.first }

  it do
    expect(subject).to define_enum_for(:status)
      .without_instance_methods.with_values({
        active: "active",
        expired: "expired",
        revoked: "revoked",
      }).backed_by_column_of_type(:string)
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:revoked_by).optional }
  end

  describe "scopes" do
    describe "::will_expire" do
      let!(:active_token_will_expire_today) { create(:authentication_token, expires_at: date) }
      let!(:active_token_should_have_expired_yesterday) { create(:authentication_token, expires_at: 1.day.ago) }
      let!(:active_token_will_expire_in_the_future) { create(:authentication_token) }
      let!(:expired_token) { create(:authentication_token, :expired) }
      let!(:revoked_token) { create(:authentication_token, :revoked) }

      let(:date) { Time.current.to_date }

      context "when date is present" do
        it "returns only the active tokens which will expire at the provided date" do
          expect(described_class.will_expire(date)).to contain_exactly(
            active_token_will_expire_today, active_token_should_have_expired_yesterday
          )
        end
      end

      context "when date is not present" do
        it "returns all the active tokens" do
          expect(described_class.will_expire).to contain_exactly(
            active_token_will_expire_today,
            active_token_should_have_expired_yesterday,
            active_token_will_expire_in_the_future,
          )
        end
      end
    end
  end

  describe "::legacy_hash_token" do
    let(:unhashed_token) { "test_#{SecureRandom.hex(10)}" }
    let(:hashed_token) { Digest::SHA256.hexdigest(unhashed_token) }

    it "hashes the token with SHA256" do
      expect(described_class.legacy_hash_token(unhashed_token)).to eq(hashed_token)
    end
  end

  describe "::hash_token" do
    let(:unhashed_token) { "test_#{SecureRandom.hex(32)}" }
    let(:hashed_token) { OpenSSL::HMAC.hexdigest("SHA256", described_class::SECRET_KEY, unhashed_token) }

    it "hashes the token with HMAC SHA256" do
      expect(described_class.hash_token(unhashed_token)).to eq(hashed_token)
    end
  end

  describe "::create_with_random_token" do
    let(:result) do
      described_class.create_with_random_token(
        provider: provider,
        name: "Provider test token",
        expires_at: 6.months.from_now,
        created_by: user,
      )
    end
    let(:token) { "Bearer #{result.token}" }

    subject(:authentication_token) { result }

    it "creates a new AuthenticationToken" do
      expect(authentication_token).to be_persisted
      expect(authentication_token).to be_active
    end

    it "does not set the hashed_token" do
      expect(authentication_token.hashed_token).to be_nil
    end

    it "sets the token_hash" do
      token_hash = OpenSSL::HMAC.hexdigest(
        "SHA256", Rails.application.key_generator.generate_key("api-token:v1", 32), authentication_token.token
      )

      expect(authentication_token.token_hash).to eq(token_hash)
    end

    it "sets the provider_id" do
      expect(authentication_token.provider_id).to eq(provider.id)
    end

    it "includes the environment name in the token" do
      expect(token.split.last.split("_").first).to eq("test")
    end

    context "when the hashed token already exists" do
      let(:hex) { SecureRandom.hex(32) }
      let(:new_hex) { SecureRandom.hex(32) }

      let(:hashed_token) { described_class.hash_token("test_#{hex}") }

      let!(:existing_token) { create(:authentication_token, hashed_token:) }

      before do
        allow(SecureRandom).to receive(:hex).with(32).and_return(hex, new_hex)
      end

      it "creates another hashed token" do
        expect(subject).to be_persisted
      end
    end
  end

  describe "::authenticate" do
    context "when an HMAC token exists" do
      let!(:authentication_token) do
        described_class.create_with_random_token(
          name: "hmac_token",
          provider: provider,
          expires_at: 6.months.from_now,
          created_by: user,
        )
      end

      it "returns the token" do
        expect(
          described_class.authenticate(authentication_token.token),
        ).to eq(authentication_token)
      end
    end

    context "when an non HMAC token exists" do
      let(:token) { "test_#{SecureRandom.hex(10)}" }
      let(:hashed_token) { described_class.legacy_hash_token(token) }

      let(:secret_key) { Rails.application.key_generator.generate_key("api-token:v1", 32) }
      let(:token_hash) { OpenSSL::HMAC.hexdigest("SHA256", secret_key, token) }

      let!(:authentication_token) do
        create(:authentication_token, hashed_token:)
      end

      it "returns the token converted to an HMAC token" do
        expect(described_class.authenticate(token)).to eq(authentication_token)
        expect(authentication_token.reload.hashed_token).to eq(hashed_token)

        expect(authentication_token.token_hash).to eq(token_hash)
        expect(described_class.authenticate(token)).to eq(authentication_token.reload)
      end
    end

    context "when the token does not exist" do
      let(:token) { "test_#{SecureRandom.hex(32)}" }

      let!(:authentication_token) do
        create(:authentication_token)
      end

      it "returns nil" do
        expect(described_class.authenticate(token)).to be_nil
      end
    end
  end

  describe "events" do
    subject(:authentication_token) { create(:authentication_token) }

    before do
      Current.user = user
    end

    after do
      Current.user = nil
    end

    describe ".revoke!" do
      let(:current_time) { Time.current.beginning_of_day }

      it "revokes the token" do
        Timecop.freeze(current_time) do
          subject.revoke!

          expect(subject.revoked?).to be(true)
          expect(subject.revoked_by).to eq(user)
          expect(subject.revoked_at).to eq(current_time)
        end
      end
    end

    describe ".expire!" do
      it "revokes the token" do
        subject.expire!

        expect(subject.expired?).to be(true)
      end
    end
  end

  describe ".update_last_used_at!" do
    subject(:authentication_token) { create(:authentication_token, last_used_at:) }

    context "when the token has been used previously during the current day" do
      let(:last_used_at) { Time.zone.local(2025, 3, 15, 1) }

      it "does not update last_used_at" do
        Timecop.travel(Time.zone.local(2025, 3, 15, 2)) do
          subject.update_last_used_at!
          expect(subject.last_used_at).to eq(last_used_at)
        end
      end
    end

    context "when the token has not been used previously during the current day" do
      let(:last_used_at) { 1.day.ago }

      it "updates last_used_at" do
        Timecop.freeze do
          subject.update_last_used_at!
          expect(subject.last_used_at).to be_within(1.second).of(Time.current)
        end
      end
    end
  end
end

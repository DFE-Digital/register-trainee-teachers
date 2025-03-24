# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthenticationToken do
  let(:user) { create(:user, :with_multiple_organisations) }
  let(:provider) { user.providers.first }

  it do
    expect(subject).to define_enum_for(:status)
      .without_instance_methods.with_values({
        active: "active",
        expired: "expired",
        revoked: "revoked",
      }).backed_by_column_of_type(:string)
  end

  describe "validations" do
    subject(:authentication_token) { build(:authentication_token) }

    it { is_expected.to validate_uniqueness_of(:hashed_token) }
    it { is_expected.to validate_length_of(:name).is_at_most(200) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:revoked_by).optional }
  end

  describe "scopes" do
    describe "::will_expire" do
      let!(:active_token) { create(:authentication_token) }
      let!(:active_token_will_expire_today) { create(:authentication_token, expires_at: date) }
      let!(:active_token_will_expire_in_the_future) { create(:authentication_token, :will_expire) }
      let!(:expired_token) { create(:authentication_token, :expired) }
      let!(:revoked_token) { create(:authentication_token, :will_expire, :revoked) }

      let(:date) { Time.current.to_date }

      context "when date is present" do
        it "returns only the active tokens which will expire at the provided date" do
          expect(described_class.will_expire(date)).to contain_exactly(active_token_will_expire_today)
        end
      end

      context "when date is not present" do
        it "returns all the active tokens with an expired_at date" do
          expect(described_class.will_expire).to contain_exactly(
            active_token_will_expire_today, active_token_will_expire_in_the_future
          )
        end
      end
    end
  end

  describe ".create_with_random_token" do
    let(:token) { "Bearer #{described_class.create_with_random_token(provider_id: provider.id, name: 'Provider test token', created_by: user)}" }

    subject(:authentication_token) { AuthenticationToken.authenticate(token) }

    it "creates a new AuthenticationToken" do
      expect(authentication_token).to be_persisted
      expect(authentication_token).to be_active
    end

    it "sets the hashed_token" do
      expect(authentication_token.hashed_token).not_to be_nil
    end

    it "sets the provider_id" do
      expect(authentication_token.provider_id).to eq(provider.id)
    end

    it "includes the environment name in the token" do
      expect(token.split.last.split("_").first).to eq("test")
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
end

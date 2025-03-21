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
          expect(subject.last_used_at).to eq(Time.current)
        end
      end
    end
  end
end

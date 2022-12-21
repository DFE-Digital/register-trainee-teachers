# frozen_string_literal: true

require "rails_helper"

describe OtpSignInUser do
  describe ".load_from_session" do
    subject(:service) { described_class.load_from_session(session) }

    let(:session) { { "otp_sign_in_user" => { "last_active_at" => last_active_at } }.with_indifferent_access }

    context "with a user that has signed in and has been recently active" do
      let(:last_active_at) { Time.zone.now }

      it { expect(service).not_to be_nil }
    end

    context "when the user has signed in and has not been recently active" do
      let(:last_active_at) { 1.day.ago }

      it { expect(service).to be_nil }
    end

    context "returns nil when the user has not signed in" do
      let(:session) { { "dfe_sign_in_user" => nil }.with_indifferent_access }

      it { expect(service).to be_nil }
    end

    context "when the user does not have a last active timestamp" do
      let(:session) { { "dfe_sign_in_user" => { "last_active_at" => nil } } }

      it { expect(service).to be_nil }
    end
  end

  describe "#user" do
    subject(:service) { described_class.load_from_session(session) }

    let(:user) { create(:user) }
    let(:session) do
      {
        "otp_sign_in_user" => {
          "last_active_at" => Time.zone.now,
          "email" => user.email,
        },
      }.with_indifferent_access
    end

    it "returns the correct user" do
      expect(service.user).to eql user
    end
  end
end

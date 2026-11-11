# frozen_string_literal: true

require "rails_helper"

# rubocop:disable-next RSpec/SpecFilePathFormat
describe DfESignInUser do
  describe ".load_from_session" do
    it "returns the DfE User when the user has signed in and has been recently active" do
      session = { "dfe_sign_in_user" => { "last_active_at" => Time.zone.now } }

      signin_user = DfESignInUser.load_from_session(session)
      expect(signin_user).not_to be_nil
    end

    it "returns nil when the user has signed in and has not been recently active" do
      session = { "dfe_sign_in_user" => { "last_active_at" => 1.day.ago } }

      signin_user = DfESignInUser.load_from_session(session)

      expect(signin_user).to be_nil
    end

    it "returns nil when the user has not signed in" do
      session = { "dfe_sign_in_user" => nil }

      signin_user = DfESignInUser.load_from_session(session)

      expect(signin_user).to be_nil
    end

    it "returns nil when the user does not have a last active timestamp" do
      session = { "dfe_sign_in_user" => { "last_active_at" => nil } }

      signin_user = DfESignInUser.load_from_session(session)

      expect(signin_user).to be_nil
    end
  end

  describe "#system_admin?" do
    let(:discarded_at) { nil }
    let(:user) { create(:user, system_admin:, discarded_at:) }

    subject(:signin_user) do
      described_class.new(
        dfe_sign_in_uid: user.dfe_sign_in_uid,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
      )
    end

    context "when user is not a system admin" do
      let(:system_admin) { false }

      it "returns false" do
        expect(signin_user).not_to be_system_admin
      end
    end

    context "when user is a soft-deleted system admin" do
      let(:system_admin) { true }
      let(:discarded_at) { 1.day.ago }

      it "returns false" do
        expect(signin_user).not_to be_system_admin
      end
    end

    context "when user is a system admin" do
      let(:system_admin) { true }

      it "returns true" do
        expect(signin_user).to be_system_admin
      end
    end
  end

  describe "#user" do
    subject(:resolved_user) do
      described_class.new(
        dfe_sign_in_uid: session_uid,
        email: session_email,
        first_name: "Example",
        last_name: "User",
      ).user
    end

    let(:session_uid) { "6dd394f1-df7d-45f1-976e-687190390d62" }
    let(:session_email) { "alice@example.com" }

    context "when a user matches by dfe_sign_in_uid" do
      let!(:user) do
        create(
          :user,
          dfe_sign_in_uid: session_uid,
          email: "other@example.com",
        )
      end

      it "returns that user" do
        expect(resolved_user).to eq(user)
      end
    end

    context "when no user matches by uid and the email matches a user with no stored uid" do
      let!(:user) do
        create(
          :user,
          dfe_sign_in_uid: nil,
          email: "Alice@example.com",
        )
      end

      it "returns that user" do
        expect(resolved_user).to eq(user)
      end
    end

    context "when no user matches by uid and the email matches a user with a different uid" do
      let!(:user) do
        create(
          :user,
          dfe_sign_in_uid: "different-uid",
          email: session_email,
        )
      end

      it "refuses the sign in" do
        expect(resolved_user).to be_nil
      end

      it "logs the refusal with the register user id only" do
        allow(Rails.logger).to receive(:warn)

        resolved_user

        expect(Rails.logger).to have_received(:warn).with(
          "DSI sign-in refused: dfe_sign_in_uid mismatch for user_id=#{user.id}",
        )
      end
    end

    context "when no user matches by uid or email" do
      it "returns nil" do
        expect(resolved_user).to be_nil
      end
    end
  end

  describe "#logout_url" do
    it "returns the dfe logout url" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "123",
          "provider" => "dfe",
        },
      }
      dfe_sign_in_user = described_class.load_from_session(session)
      request = instance_double(ActionDispatch::Request, base_url: "dfe_url")

      expect(dfe_sign_in_user.logout_url(request)).to eq(
        "https://test-oidc.signin.education.gov.uk/session/end?id_token_hint=" \
        "123&post_logout_redirect_uri=dfe_url%2Fauth%2Fdfe%2Fsign-out",
      )
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe SystemAdminConstraint do
  let(:request) { double(session: session) }
  let(:session) { double }
  let(:dfe_signin_user) { double(email: email) }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(dfe_signin_user)
  end

  describe "#matches?" do
    subject { SystemAdminConstraint.new.matches?(request) }

    context "system admin" do
      let(:email) { "dave@example.com" }
      let!(:system_admin) { create(:user, :system_admin, email: email) }

      it { is_expected.to eq(true) }
    end

    context "non system admin" do
      let(:email) { "dave@example.com" }
      let!(:user) { create(:user, email: email) }

      it { is_expected.to eq(false) }
    end

    context "discarded system admin" do
      let(:email) { "dave@example.com" }
      let!(:system_admin) { create(:user, :system_admin, email: email) }

      before do
        system_admin.discard!
      end

      it { is_expected.to eq(false) }
    end

    context "no matching user" do
      let(:email) { "dave@example.com" }
      let!(:system_admin) { create(:user, email: "dennis@example.com") }

      it { is_expected.to eq(false) }
    end

    context "no DfESigninUser (the session has ended)" do
      let(:email) { "dave@example.com" }
      let!(:system_admin) { create(:user, email: "dennis@example.com") }
      let(:dfe_signin_user) { nil }

      it { is_expected.to eq(false) }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe SystemAdminConstraint do
  let(:request) { double(session:) }
  let(:session) { double }

  context "with a DfESignInUser" do
    let(:dfe_signin_user) { double(system_admin?: system_admin) }

    before do
      allow(DfESignInUser).to receive(:load_from_session).and_return(dfe_signin_user)
      allow(OtpSignInUser).to receive(:load_from_session).and_return(nil)
    end

    describe "#matches?" do
      subject { SystemAdminConstraint.new.matches?(request) }

      context "system admin" do
        let(:system_admin) { true }

        it { is_expected.to be(true) }
      end

      context "non system admin" do
        let(:system_admin) { false }

        it { is_expected.to be(false) }
      end
    end
  end

  context "with a OtpSignInUser" do
    let(:otp_signin_user) { double(system_admin?: system_admin) }

    before do
      allow(DfESignInUser).to receive(:load_from_session).and_return(nil)
      allow(OtpSignInUser).to receive(:load_from_session).and_return(otp_signin_user)
    end

    describe "#matches?" do
      subject { SystemAdminConstraint.new.matches?(request) }

      context "system admin" do
        let(:system_admin) { true }

        it { is_expected.to be(true) }
      end

      context "non system admin" do
        let(:system_admin) { false }

        it { is_expected.to be(false) }
      end
    end
  end
end

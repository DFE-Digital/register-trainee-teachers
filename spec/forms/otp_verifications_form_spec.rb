# frozen_string_literal: true

require "rails_helper"

describe OtpVerificationsForm, type: :model do
  subject(:form) { described_class.new(session:, code:) }

  let(:error_message) do
    form.valid?
    form.try(:errors).try(:first).try(:message).to_s
  end

  let(:code) { "1234" }
  let(:user) { create(:user, :with_otp_secret) }

  let(:otp_salt) { ROTP::Base32.random(16) }
  let(:otp_email) { Faker::Internet.email }
  let(:otp_attempts) { 0 }
  let(:otp_last_attempt) { Time.zone.now }

  let(:session) do
    {
      otp_salt:,
      otp_email:,
      otp_attempts:,
      otp_last_attempt:,
    }
  end

  describe "#valid?" do
    context "with a user" do
      let(:otp_email) { user.email }

      describe "validating cool down" do
        context "when should not cool down" do
          let(:otp_attempts) { 0 }

          it { expect(error_message).not_to include "Please wait 1 minute before trying again" }
        end

        context "when should cool down" do
          let(:otp_attempts) { 5 }

          it { expect(error_message).to include "Please wait 1 minute before trying again" }
        end
      end

      describe "validating code presence" do
        context "when there is a code" do
          let(:code) { "1234" }

          it do
            expect(error_message).not_to include "Enter the code from your email"
          end
        end

        context "when there is no code" do
          let(:code) { nil }

          it do
            expect(error_message).to include "Enter the code from your email"
          end
        end
      end

      describe "validating the code" do
        context "when the code is correct" do
          let(:code) { ROTP::TOTP.new(user.otp_secret + otp_salt, issuer: "Register").now }

          it { expect(form.valid?).to be true }
        end

        context "when the code is incorrect" do
          it { expect(error_message).to include "The code is incorrect or has expired" }
        end
      end
    end

    # user has submitted an email that is not in our databse
    context "without a user" do
      describe "validating cool down" do
        context "when should not cool down" do
          let(:otp_attempts) { 0 }

          it { expect(error_message).not_to include "Please wait 1 minute before trying again" }
        end

        context "when should cool down" do
          let(:otp_attempts) { 5 }

          it { expect(error_message).to include "Please wait 1 minute before trying again" }
        end
      end

      describe "validating code presence" do
        context "when there is a code" do
          let(:code) { "1234" }

          it do
            expect(error_message).not_to include "Enter the code from your email"
          end
        end

        context "when there is no code" do
          let(:code) { nil }

          it do
            expect(error_message).to include "Enter the code from your email"
          end
        end
      end
    end
  end
end

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

  let(:session) do
    {
      otp_salt:,
      otp_email:,
    }
  end

  describe "#valid?" do
    context "with a user" do
      let(:otp_email) { user.email }

      describe "validating rate limit" do
        let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

        before do
          allow(Rails).to receive(:cache).and_return(memory_store)
        end

        context "when within the limit" do
          it { expect(error_message).not_to include "Please wait 5 minutes before trying again" }
        end

        context "when the limit is exceeded" do
          before do
            5.times { described_class.new(session:, code:).valid? }
          end

          it { expect(error_message).to include "Please wait 5 minutes before trying again" }

          context "with a correct code" do
            let(:code) { ROTP::TOTP.new(user.otp_secret + otp_salt, issuer: "Register").now }

            it "is not valid" do
              expect(form.valid?).to be false
            end
          end
        end

        context "when there is no code" do
          let(:code) { nil }

          it "does not count the attempt" do
            expect(EmailRateLimiter).not_to receive(:call)
            expect(form.valid?).to be false
          end
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
      describe "validating rate limit" do
        let(:memory_store) { ActiveSupport::Cache::MemoryStore.new }

        before do
          allow(Rails).to receive(:cache).and_return(memory_store)
        end

        context "when within the limit" do
          it { expect(error_message).not_to include "Please wait 5 minutes before trying again" }
        end

        context "when the limit is exceeded" do
          before do
            5.times { described_class.new(session:, code:).valid? }
          end

          it { expect(error_message).to include "Please wait 5 minutes before trying again" }
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

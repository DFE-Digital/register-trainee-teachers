# frozen_string_literal: true

require "rails_helper"

module DfESignInUsers
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(user:, sign_in_user:) }

      context "when user details are valid and the user has no stored uid" do
        let(:user) { create(:user, dfe_sign_in_uid: nil) }

        let(:sign_in_user) do
          template = build(:user)
          DfESignInUser.new(email: template.email,
                            dfe_sign_in_uid: template.dfe_sign_in_uid,
                            first_name: template.first_name,
                            last_name: template.last_name)
        end

        before do
          service
          user.reload
        end

        it "updates the user's details including storing the uid" do
          expect(user.email).to eq(sign_in_user.email)
          expect(user.dfe_sign_in_uid).to eq(sign_in_user.dfe_sign_in_uid)
          expect(user.first_name).to eq(sign_in_user.first_name)
          expect(user.last_name).to eq(sign_in_user.last_name)
          expect(user.last_signed_in_at).to be_present
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when the user is matched by uid and the email has changed" do
        let(:user) { create(:user, email: "old@example.com") }

        let(:sign_in_user) do
          DfESignInUser.new(email: "New@example.com",
                            dfe_sign_in_uid: user.dfe_sign_in_uid,
                            first_name: "Updated",
                            last_name: "Name")
        end

        it "updates email, name and last signed in without changing the uid" do
          expect { service }.to change { user.reload.email }.to("new@example.com")
            .and change(user, :first_name).to("Updated")
            .and change(user, :last_name).to("Name")
            .and not_change(user, :dfe_sign_in_uid)

          expect(user.reload.last_signed_in_at).to be_present
          expect(service).to be_successful
        end

        it "logs the email change with the register user id only" do
          allow(Rails.logger).to receive(:info)

          service

          expect(Rails.logger).to have_received(:info).with(
            "DSI sign-in: email updated for user_id=#{user.id}",
          )
        end
      end

      context "when the user already has a stored uid and sign in provides a different one" do
        let(:user) { create(:user, dfe_sign_in_uid: "existing-uid") }
        let(:original_uid) { user.dfe_sign_in_uid }

        let(:sign_in_user) do
          DfESignInUser.new(email: user.email,
                            dfe_sign_in_uid: "different-uid",
                            first_name: user.first_name,
                            last_name: user.last_name)
        end

        it "does not overwrite the stored uid" do
          service
          expect(user.reload.dfe_sign_in_uid).to eq(original_uid)
          expect(service).to be_successful
        end
      end

      context "when the email only differs by case" do
        let(:user) { create(:user, email: "Alice@example.com") }

        let(:sign_in_user) do
          DfESignInUser.new(email: "alice@example.com",
                            dfe_sign_in_uid: user.dfe_sign_in_uid,
                            first_name: user.first_name,
                            last_name: user.last_name)
        end

        it "does not log an email change" do
          allow(Rails.logger).to receive(:info)

          service

          expect(Rails.logger).not_to have_received(:info).with(
            a_string_matching(/email updated/),
          )
        end
      end

      context "when the user's details are invalid" do
        let(:user) { create(:user) }

        let(:sign_in_user) do
          DfESignInUser.new(email: nil,
                            dfe_sign_in_uid: nil,
                            first_name: nil,
                            last_name: nil)
        end

        it "does not update the user's details" do
          expect { service }.not_to(change { user.reload.email })
          expect(service).not_to be_successful
        end
      end
    end
  end
end

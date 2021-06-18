# frozen_string_literal: true

require "rails_helper"

module DfESignInUsers
  describe Update do
    describe ".call" do
      let(:service) { described_class.call(user: user, dfe_sign_in_user: dfe_sign_in_user) }

      context "when user are valid" do
        let(:user) { create(:user) }

        let(:dfe_sign_in_user) do
          template = build(:user)
          DfESignInUser.new(email: template.email,
                            dfe_sign_in_uid: template.dfe_sign_in_uid,
                            first_name: template.first_name,
                            last_name: template.last_name)
        end

        before do
          service.call
          user.reload
        end

        it "updates the user's details" do
          expect(user.email).to eq(dfe_sign_in_user.email)
          expect(user.dfe_sign_in_uid).to eq(dfe_sign_in_user.dfe_sign_in_uid)
          expect(user.first_name).to eq(dfe_sign_in_user.first_name)
          expect(user.last_name).to eq(dfe_sign_in_user.last_name)
        end

        it "is successful" do
          expect(service).to be_successful
        end
      end

      context "when the user's details are invalid" do
        let(:user) { create(:user) }

        let(:dfe_sign_in_user) do
          DfESignInUser.new(email: nil,
                            dfe_sign_in_uid: nil,
                            first_name: nil,
                            last_name: nil)
        end

        before do
          service.call
          user.reload
        end

        it "does not update the user's details" do
          expect(user.email).not_to eq(dfe_sign_in_user.email)
          expect(user.dfe_sign_in_uid).not_to eq(dfe_sign_in_user.dfe_sign_in_uid)
          expect(user.first_name).not_to eq(dfe_sign_in_user.first_name)
          expect(user.last_name).not_to eq(dfe_sign_in_user.last_name)
        end

        it "is unsuccessful" do
          expect(service).not_to be_successful
        end
      end
    end
  end
end

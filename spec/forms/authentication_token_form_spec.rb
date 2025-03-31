# frozen_string_literal: true

require "rails_helper"

describe AuthenticationTokenForm, type: :model do
  let(:params) { {} }
  let(:user) { UserWithOrganisationContext.new(user: build(:user, :hei), session: {}) }

  subject { described_class.new(user, params:) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "#save!" do
    let(:authentication_token) { build(:authentication_token) }

    before do
      allow(AuthenticationToken).to receive(:create_with_random_token).and_return(authentication_token)
    end

    context "without an expiry date" do
      let(:params) { { name: "New token" } }

      it "generates a new token" do
        expect(AuthenticationToken).to receive(:create_with_random_token).with(
          provider: user.organisation,
          created_by: user,
          name: "New token",
          expires_at: nil,
        )
        subject.save!

        expect(subject.authentication_token).to eq(authentication_token)
      end
    end

    context "with an expiry date" do
      let(:params) { { name: "New token", year: "2025", month: "12", day: "25" } }

      it "generates a new token" do
        expect(AuthenticationToken).to receive(:create_with_random_token).with(
          provider: user.organisation,
          created_by: user,
          name: "New token",
          expires_at: Date.new(2025, 12, 25),
        )
        subject.save!

        expect(subject.authentication_token).to eq(authentication_token)
      end
    end
  end
end

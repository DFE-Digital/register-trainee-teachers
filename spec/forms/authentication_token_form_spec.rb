# frozen_string_literal: true

require "rails_helper"

describe AuthenticationTokenForm, type: :model do
  let(:user) { UserWithOrganisationContext.new(user: create(:user, :hei), session: {}) }

  let(:params) { {} }

  subject { described_class.new(user, params:) }

  describe "validations" do
    describe "#name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(200) }
    end

    describe "#expires_at" do
      let(:params) { { name: "Token name", day: date.day, month: date.month, year: date.year } }

      context "when not a date" do
        let(:date) { OpenStruct.new(day: Faker::Alphanumeric.alpha, month: Date.current.month, year: Date.current.year) }

        it "returns false" do
          expect(subject.valid?).to be(false)
          expect(subject.errors[:expires_at]).to contain_exactly("Enter a valid expiration date")
        end
      end

      context "when in the past" do
        let(:date) { Date.yesterday }

        it "returns false" do
          expect(subject.valid?).to be(false)
          expect(subject.errors[:expires_at]).to contain_exactly("Expiration date must be in the future")
        end
      end

      context "when in the present" do
        let(:date) { Date.current }

        it "returns false" do
          expect(subject.valid?).to be(false)
          expect(subject.errors[:expires_at]).to contain_exactly("Expiration date must be in the future")
        end
      end

      context "when in the future" do
        let(:date) { Date.tomorrow }

        it "returns true" do
          expect(subject.valid?).to be(true)
        end
      end
    end
  end

  describe "#save!" do
    context "without an expiry date" do
      let(:params) { { name: "New token" } }

      it "generates a new token" do
        expect {
          subject.save!
        }.to change {
          AuthenticationToken.count
        }.by(1)

        token = subject.authentication_token

        expect(token.provider).to eq(user.organisation)
        expect(token.created_by).to eq(user)
        expect(token.name).to eq("New token")
        expect(token.expires_at).to be_nil
      end
    end

    context "with an expiry date" do
      let(:params) { { name: "New token", year: "2025", month: "12", day: "25" } }

      it "generates a new token" do
        expect {
          subject.save!
        }.to change {
          AuthenticationToken.count
        }.by(1)

        token = subject.authentication_token

        expect(token.provider).to eq(user.organisation)
        expect(token.created_by).to eq(user)
        expect(token.name).to eq("New token")
        expect(token.expires_at).to eq(Date.new(2025, 12, 25))
      end
    end
  end
end

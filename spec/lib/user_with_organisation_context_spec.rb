# frozen_string_literal: true

require "rails_helper"

describe UserWithOrganisationContext do
  let(:user) { double(id: 1, boo: "yah", providers: ["first"]) }
  let(:session) { {} }

  subject do
    described_class.new(user: user, session: session)
  end

  it "delegates missing methods to user" do
    expect(subject.boo).to eq("yah")
    expect(subject.id).to eq(1)
  end

  describe "#organisation" do
    subject { super().organisation }

    context "feature is not enabled" do
      # TODO: this is placeholder behaviour until we
      # start setting the current organisation context in the
      # session
      before do
        disable_features(:user_can_have_multiple_organisations)
      end

      it { is_expected.to eq(user.providers.first) }
    end

    context "multi organisation feature is enabled" do
      before do
        enable_features(:user_can_have_multiple_organisations)
      end

      # The correct behaviour. Return the provider or lead school
      it "returns the current organisation as set in the session"
    end
  end

  describe "#user" do
    subject { super().user }

    it { is_expected.to eq(user) }
  end

  describe "#is_a?" do
    it "pretends to be a user" do
      expect(subject.is_a?(User)).to eq(true)
    end
  end

  describe "#class_name" do
    it "pretends to be a user" do
      expect(subject.class_name).to eq("User")
    end
  end

  describe ".primary_key" do
    it "returns 'id'" do
      expect(described_class.primary_key).to eq("id")
    end
  end
end

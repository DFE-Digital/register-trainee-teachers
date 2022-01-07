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
    # TODO: this is placeholder behaviour until we
    # start setting the current organisation context in the
    # session

    it { is_expected.to eq(user.providers.first) }

    # The correct behaviour. Return the provider or lead school
    it "returns the current organisation as set in the session"
  end

  describe "#user" do
    subject { super().user }

    it { is_expected.to eq(user) }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Provider do
  context "fields" do
    it "validates presence" do
      expect(subject).to validate_presence_of(:name).with_message("You must enter a provider name")
      expect(subject).to validate_presence_of(:dttp_id).with_message("You must enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
      expect(subject).to validate_presence_of(:code).with_message("You must enter a provider code in the correct format, like 12Y")
    end

    it "validates format" do
      subject.dttp_id = "XXX"
      subject.code = "abcd 1234"
      subject.valid?
      expect(subject.errors[:dttp_id]).to include("You must enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
      expect(subject.errors[:code]).to include("You must enter a provider code in the correct format, like 12Y")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:users) }
  end

  describe "auditing" do
    it { should be_audited }
    it { should have_associated_audits }
  end
end

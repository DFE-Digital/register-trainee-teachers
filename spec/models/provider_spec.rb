# frozen_string_literal: true

require "rails_helper"

describe Provider do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:name).with_message("You must enter a provider name")
      expect(subject).to validate_presence_of(:dttp_id).with_message("You must enter a DTTP ID in the correct format, like b77c821a-c12a-4133-8036-6ef1db146f9e")
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

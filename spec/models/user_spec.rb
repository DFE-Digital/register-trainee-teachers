# frozen_string_literal: true

require "rails_helper"

describe User do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:first_name)
      expect(subject).to validate_presence_of(:last_name)
      expect(subject).to validate_presence_of(:email)
      expect(subject).to validate_presence_of(:dttp_id).with_message("You must enter a DTTP ID in the correct format, like 6a61d94f-5060-4d57-8676-bdb265a5b949")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "indexes" do
    it { should have_db_index(:dfe_sign_in_uid).unique(true) }
  end

  describe "auditing" do
    it { should be_audited.associated_with(:provider) }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe User do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:first_name)
      expect(subject).to validate_presence_of(:last_name)
      expect(subject).to validate_presence_of(:email)
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
  end

  describe "indexes" do
    it { should have_db_index(:dfe_sign_in_uid).unique(true) }
  end
end

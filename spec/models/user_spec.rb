# frozen_string_literal: true

require "rails_helper"

describe User do
  context "fields" do
    it "validates" do
      expect(subject).to validate_presence_of(:first_name)
      expect(subject).to validate_presence_of(:last_name)
      expect(subject).to validate_presence_of(:email)
      expect(subject).to validate_presence_of(:dttp_id).with_message("Enter a DTTP ID in the correct format, like 6a61d94f-5060-4d57-8676-bdb265a5b949")
    end

    context "system_admin" do
      before { subject.system_admin = true }

      it "allows empty dttp_id" do
        expect(subject).not_to validate_presence_of(:dttp_id).with_message("Enter a DTTP ID in the correct format, like 6a61d94f-5060-4d57-8676-bdb265a5b949")
      end
    end
  end

  context "validates dttp_id" do
    subject { create(:user) }

    it "validates uniqueness" do
      expect(subject).to validate_uniqueness_of(:dttp_id).case_insensitive.with_message("Enter a unique DTTP ID")
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:dfe_sign_in_uid).unique(true) }
    it { is_expected.to have_db_index(:dttp_id).unique(true) }
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:provider) }
  end

  describe "#discard" do
    subject { create(:user) }

    context "before discarding" do
      it { is_expected.not_to be_discarded }

      it "is in kept" do
        expect(User.kept).to eq([subject])
      end

      it "is not in discarded" do
        expect(User.discarded).to be_empty
      end
    end

    context "after discarding" do
      before do
        subject.discard
      end

      it { is_expected.to be_discarded }

      it "is not in kept" do
        expect(User.kept).to be_empty
      end

      it "is in discarded" do
        expect(User.discarded).to eq([subject])
      end
    end
  end
end

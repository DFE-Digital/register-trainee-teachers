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

  describe "#active_user?" do
    let(:first_user) { create(:user) }

    subject { build(:user) }

    context "user with same dttp_id as active user" do
      before do
        subject.dttp_id = first_user.dttp_id
        subject.save
      end

      it "errors" do
        expect(subject.errors[:dttp_id]).to include(I18n.t("activerecord.errors.models.user.attributes.dttp_id.taken"))
      end
    end

    context "user with same dttp_id as inactive user" do
      before do
        subject.dttp_id = first_user.dttp_id
        first_user.discard
        subject.save
      end

      it "allows user to be saved" do
        expect(subject.errors[:dttp_id]).not_to include(I18n.t("activerecord.errors.models.user.attributes.dttp_id.taken"))
      end
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:providers) }
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:dfe_sign_in_uid).unique(true) }
    it { is_expected.to have_db_index(:dttp_id).unique(true) }
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

  describe ".system_admins" do
    context "a system admin" do
      let!(:system_admin) { create(:user, :system_admin) }

      it "is returned" do
        expect(User.system_admins).to contain_exactly(system_admin)
      end
    end

    context "a non-system admin" do
      let!(:user) { create(:user) }

      it "is not returned" do
        expect(User.system_admins).to be_empty
      end
    end
  end

  describe ".primary_provider" do
    subject { create(:user) }

    context "returns first provider" do
      it { expect(subject.primary_provider).to eq(subject.providers.first) }
    end
  end
end

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

  context "uniqueness validations" do
    subject { create(:user) }

    it "validates uniqueness of email" do
      expect(subject).to validate_uniqueness_of(:email).ignoring_case_sensitivity.with_message("Enter a unique email address")
    end
  end

  describe "#active_user?" do
    let(:first_user) { create(:user) }

    subject { build(:user) }

    context "user with same email as active user" do
      before do
        subject.email = first_user.email
        subject.save
      end

      it "errors" do
        expect(subject.errors[:email]).to include(I18n.t("activerecord.errors.models.user.attributes.email.taken"))
      end
    end

    context "user with same email as inactive user" do
      before do
        subject.email = first_user.email
        first_user.discard
        subject.save
      end

      it "allows user to be saved" do
        expect(subject.errors[:email]).not_to include(I18n.t("activerecord.errors.models.user.attributes.email.taken"))
      end
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:providers) }
    it { is_expected.to have_many(:provider_users) }
    it { is_expected.to have_many(:training_partner_users) }
    it { is_expected.to have_many(:training_partners).through(:training_partner_users) }

    it do
      expect(subject).to have_many(:submitted_bulk_update_trainee_uploads)
      .class_name("BulkUpdate::TraineeUpload").with_foreign_key(:submitted_by_id)
    end
  end

  describe "indexes" do
    it { is_expected.to have_db_index(:dfe_sign_in_uid).unique(true) }
    it { is_expected.to have_db_index(:email).unique(true) }
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

  describe "#generate_otp_secret!" do
    subject(:user) { create(:user) }

    it { expect(user.generate_otp_secret!).not_to be_nil }
  end
end

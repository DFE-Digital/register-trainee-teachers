# frozen_string_literal: true

require "rails_helper"

describe FindInactiveUsers do
  let(:cutoff) { 365.days.ago }

  subject(:inactive_users) { described_class.call(cutoff:) }

  context "when the user last signed in before the cutoff" do
    let!(:user) { create(:user, last_signed_in_at: cutoff - 1.second) }

    it "includes the user" do
      expect(inactive_users).to include(user)
    end
  end

  context "when the user last signed in exactly on the cutoff" do
    let!(:user) { create(:user, last_signed_in_at: cutoff) }

    it "excludes the user" do
      expect(inactive_users).not_to include(user)
    end
  end

  context "when the user has never signed in" do
    context "with a created_at before the cutoff" do
      let!(:user) { create(:user, last_signed_in_at: nil, created_at: cutoff - 1.second) }

      it "includes the user" do
        expect(inactive_users).to include(user)
      end
    end

    context "with a created_at exactly on the cutoff" do
      let!(:user) { create(:user, last_signed_in_at: nil, created_at: cutoff) }

      it "excludes the user" do
        expect(inactive_users).not_to include(user)
      end
    end
  end

  context "when the user signed in long ago but was only created recently" do
    let!(:user) { create(:user, last_signed_in_at: cutoff - 1.second, created_at: 1.day.ago) }

    it "includes the user" do
      expect(inactive_users).to include(user)
    end
  end

  context "when no cutoff is given" do
    let!(:user) do
      create(:user, last_signed_in_at: (Settings.user_clean_up.inactive_after_days + 1).days.ago)
    end

    it "defaults to the configured inactivity period" do
      expect(described_class.call).to include(user)
    end
  end
end

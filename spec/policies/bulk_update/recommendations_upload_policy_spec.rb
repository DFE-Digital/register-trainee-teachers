# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RecommendationsUploadPolicy, type: :policy do
  subject { described_class }

  context "when the user's organisation is a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    permissions :create? do
      it { is_expected.to permit(user, :recommendations_upload) }
    end
  end

  context "when the user is read-only" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, read_only: true), session: {}) }

    permissions :create? do
      it { is_expected.not_to permit(user, :recommendations_upload) }
    end
  end

  context "when the user's organisation is a TrainingPartner" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_training_partner_organisation), session: {}) }

    permissions :create? do
      it { is_expected.not_to permit(user, :recommendations_upload) }
    end
  end
end

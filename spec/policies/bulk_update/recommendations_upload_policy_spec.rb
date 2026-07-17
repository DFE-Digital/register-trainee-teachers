# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::RecommendationsUploadPolicy, type: :policy do
  subject { described_class }

  context "when the user's organisation is a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    permissions :new?, :create?, :edit?, :update?, :show?, :confirmation?, :cancel? do
      it { is_expected.to permit(user, :recommendations_upload) }
    end
  end

  context "when the user's organisation is a Provider with read-only access" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, read_only: true), session: {}) }

    permissions :new?, :create?, :edit?, :update?, :show?, :confirmation?, :cancel? do
      it { is_expected.not_to permit(user, :recommendations_upload) }
    end
  end

  context "when the user's organisation is a TrainingPartner" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_training_partner_organisation), session: {}) }

    permissions :new?, :create?, :edit?, :update?, :show?, :confirmation?, :cancel? do
      it { is_expected.not_to permit(user, :recommendations_upload) }
    end
  end
end

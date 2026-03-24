# frozen_string_literal: true

require "rails_helper"

RSpec.describe BulkUpdate::PlacementPolicy, type: :policy do
  subject { described_class }

  context "when the user's organisation is a Provider" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user), session: {}) }

    permissions :new?, :create? do
      it { is_expected.to permit(user, :placement) }
    end
  end

  context "when the user's organisation is a TrainingPartner" do
    let(:user) { UserWithOrganisationContext.new(user: create(:user, :with_training_partner_organisation), session: {}) }

    permissions :new?, :create? do
      it { is_expected.not_to permit(user, :placement) }
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganisationSettingsPolicy, type: :policy do
  subject { described_class }

  context "when the User belongs to a Provider" do
    let(:provider_user) { create(:user) }
    let(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

    permissions :show? do
      it { is_expected.to permit(provider_user_context) }
    end
  end

  context "when the User belongs to a LeadPartner" do
    let(:lead_partner_user) { create(:user, :with_lead_partner_organisation) }
    let(:lead_partner_user_context) { UserWithOrganisationContext.new(user: lead_partner_user, session: {}) }

    permissions :show? do
      it { is_expected.to permit(lead_partner_user_context) }
    end
  end

  context "when the User does not belong to either a Provider or LeadPartner" do
    let(:user_with_no_organisation) { create(:user, :with_no_organisation_in_db) }
    let(:user_with_no_organisation_context) { UserWithOrganisationContext.new(user: user_with_no_organisation, session: {}) }

    permissions :show? do
      it { is_expected.not_to permit(user_with_no_organisation_context) }
    end
  end
end

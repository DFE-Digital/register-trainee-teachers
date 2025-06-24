# frozen_string_literal: true

require "rails_helper"

describe UserPolicy do
  subject { described_class }

  let(:school) { create(:school) }
  let(:provider) { create(:provider) }

  let(:provider_user) { create(:user, providers: [provider]) }
  let(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

  let(:provider_admin_user) { create(:user, system_admin: true) }
  let(:provider_admin_user_context) { UserWithOrganisationContext.new(user: provider_admin_user, session: {}) }

  let(:lead_partner) { create(:lead_partner, :school) }

  let(:lead_partner_user) { create(:user, :with_lead_partner_organisation, lead_partners: [lead_partner]) }
  let(:lead_partner_user_context) { UserWithOrganisationContext.new(user: lead_partner_user, session: {}) }

  let(:lead_partner_admin_user) { create(:user, :with_lead_partner_organisation, system_admin: true, lead_partners: [lead_partner]) }
  let(:lead_partner_admin_user_context) { UserWithOrganisationContext.new(user: lead_partner_admin_user, session: {}) }

  context "when drafts?, reports?" do
    permissions :drafts?, :reports? do
      it { is_expected.to permit(provider_user_context) }
      it { is_expected.to permit(lead_partner_admin_user_context) }

      it { is_expected.not_to permit(lead_partner_user_context) }
    end
  end

  context "when bulk_recommend?, bulk_placement?" do
    permissions :bulk_recommend?, :bulk_placement? do
      it { is_expected.to permit(provider_user_context) }

      it { is_expected.not_to permit(provider_admin_user_context) }
      it { is_expected.not_to permit(lead_partner_admin_user_context) }
      it { is_expected.not_to permit(lead_partner_user_context) }
    end
  end

  context "when lead_partner_user?" do
    permissions :lead_partner_user? do
      it { is_expected.to permit(lead_partner_user_context) }
      it { is_expected.to permit(lead_partner_admin_user_context) }

      it { is_expected.not_to permit(provider_user_context) }
      it { is_expected.not_to permit(provider_admin_user_context) }
    end
  end

  context "when can_access_claims_reports?" do
    let(:system_admin_user) { create(:user, :system_admin) }
    let(:system_admin_user_context) { UserWithOrganisationContext.new(user: system_admin_user, session: {}) }

    permissions :can_access_claims_reports? do
      it { is_expected.to permit(system_admin_user_context) }

      it { is_expected.not_to permit(provider_user_context) }
      it { is_expected.not_to permit(lead_partner_user_context) }
      it { is_expected.not_to permit(provider_admin_user_context) }
      it { is_expected.not_to permit(lead_partner_admin_user_context) }
    end
  end
end

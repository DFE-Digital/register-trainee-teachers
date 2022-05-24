# frozen_string_literal: true

require "rails_helper"

describe UserPolicy do
  subject { described_class }

  let(:lead_school) { create(:school, :lead) }
  let(:provider) { create(:provider) }

  let(:provider_user) { create(:user, providers: [provider]) }
  let(:provider_user_context) { UserWithOrganisationContext.new(user: provider_user, session: {}) }

  let(:lead_school_user) { create(:user, lead_schools: [lead_school]) }
  let(:lead_school_user_context) { UserWithOrganisationContext.new(user: lead_school_user, session: {}) }

  let(:lead_school_admin_user) { create(:user, system_admin: true, lead_schools: [lead_school]) }
  let(:lead_school_admin_user_context) { UserWithOrganisationContext.new(user: lead_school_admin_user, session: {}) }

  before do
    allow(lead_school_user_context).to receive(:lead_school?).and_return(true)
  end

  permissions :drafts? do
    it { is_expected.to permit(provider_user_context) }
    it { is_expected.not_to permit(lead_school_user_context) }
    it { is_expected.to permit(lead_school_admin_user_context) }
  end
end

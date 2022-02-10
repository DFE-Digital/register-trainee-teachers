# frozen_string_literal: true

require "rails_helper"

describe OrganisationContextPolicy do
  subject { described_class }

  let(:provider_user) { create(:user, providers: [provider]) }
  let(:lead_school_user) { create(:user, lead_schools: [lead_school]) }
  let(:unassociated_user) { create(:user) }
  let(:lead_school) { create(:school, :lead) }
  let(:provider) { create(:provider) }

  permissions :show? do
    it { is_expected.to permit(provider_user, provider) }
    it { is_expected.to permit(lead_school_user, lead_school) }
    it { is_expected.not_to permit(lead_school_user, provider) }
    it { is_expected.not_to permit(provider_user, lead_school) }
    it { is_expected.not_to permit(unassociated_user, lead_school) }
    it { is_expected.not_to permit(unassociated_user, provider) }
  end

  permissions :index? do
    it { is_expected.to permit(provider_user) }
  end
end

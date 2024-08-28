# frozen_string_literal: true

require "rails_helper"

RSpec.describe Degrees::TraineePolicy, type: :policy do
  let(:provider) { create(:provider) }
  let(:unaccredited_provider) { create(:provider, :unaccredited) }

  let(:provider_user) { user_with_organisation(create(:user, providers: [provider]), provider) }
  let(:unaccredited_provider_user) { user_with_organisation(create(:user, providers: [unaccredited_provider]), unaccredited_provider) }
  let(:read_only_provider_user) { user_with_organisation(create(:user, providers: [provider], read_only: true), provider) }
  let(:school) { create(:school) }
  let(:lead_partner) { create(:lead_partner, :lead_school, school:) }
  let(:lead_partner_user) { user_with_organisation(create(:user, providers: []), lead_partner) }
  let(:system_admin_user) { user_with_organisation(create(:user, :system_admin), nil) }

  let(:provider_trainee) { create(:trainee, provider:) }
  let(:lead_partner_trainee) { create(:trainee, lead_partner:) }
  let(:unaccredited_provider_trainee) { create(:trainee, provider: unaccredited_provider) }

  subject { described_class }

  def user_with_organisation(user, organisation)
    UserWithOrganisationContext.new(user: user, session: {}).tap do |user_with_org|
      allow(user_with_org).to receive(:organisation).and_return(organisation)
    end
  end

  permissions :new?, :create? do
    it { is_expected.to permit(provider_user, provider_trainee) }
    it { is_expected.to permit(system_admin_user, provider_trainee) }

    it { is_expected.not_to permit(lead_partner_user, lead_partner_trainee) }
    it { is_expected.not_to permit(read_only_provider_user, provider_trainee) }
    it { is_expected.not_to permit(unaccredited_provider_user, unaccredited_provider_trainee) }
  end
end

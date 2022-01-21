# frozen_string_literal: true

require "rails_helper"

describe TraineePolicy do
  let(:system_admin_user) { create(:user, :system_admin) }
  let(:provider) { create(:provider) }
  let(:provider_user) { create(:user, providers: [provider]) }
  let(:other_provider_user) { create(:user) }
  let(:trainee) { create(:trainee, provider: provider) }
  let(:deferred_trainee) { create(:trainee, :deferred, provider: provider) }

  subject { described_class }

  permissions :show?, :create?, :update? do
    it { is_expected.to permit(provider_user, trainee) }
    it { is_expected.to permit(system_admin_user, trainee) }
    it { is_expected.not_to permit(other_provider_user, trainee) }
  end

  permissions :reinstate? do
    it { is_expected.to permit(provider_user, deferred_trainee) }
    it { is_expected.to permit(system_admin_user, deferred_trainee) }
    it { is_expected.not_to permit(other_provider_user, deferred_trainee) }
    it { is_expected.not_to permit(provider_user, trainee) }
    it { is_expected.not_to permit(system_admin_user, trainee) }
  end

  describe TraineePolicy::Scope do
    let(:user_with_organisation) do
      double(UserWithOrganisationContext, system_admin?: is_system_admin?, organisation: organisation, lead_school?: is_lead_school?, provider?: is_provider?)
    end
    let(:is_lead_school?) { false }
    let(:is_provider?) { false }
    let(:is_system_admin?) { false }

    subject { described_class.new(user_with_organisation, Trainee).resolve }

    context "user in provider context" do
      let(:is_provider?) { true }
      let(:provider) { create(:provider) }
      let(:organisation) { provider }

      context "where the trainee is associated with the provider" do
        let(:trainee) { create(:trainee, provider: provider) }

        it { is_expected.to contain_exactly(trainee) }

        context "and the trainee is deleted" do
          let(:trainee) { create(:trainee, :discarded, provider: provider) }

          it { is_expected.not_to contain_exactly(trainee) }
        end
      end

      context "where the trainee is associated with another provider" do
        let(:trainee) { create(:trainee) }

        it { is_expected.not_to contain_exactly(trainee) }
      end
    end

    context "user in lead_school context" do
      let(:is_lead_school?) { true }
      let(:lead_school) { create(:school, :lead) }
      let(:organisation) { lead_school }

      context "where the trainee is associated with the provider" do
        let(:trainee) { create(:trainee, lead_school: lead_school) }

        it { is_expected.to contain_exactly(trainee) }

        context "and the trainee is deleted" do
          let(:trainee) { create(:trainee, :discarded, lead_school: lead_school) }

          it { is_expected.not_to contain_exactly(trainee) }
        end
      end

      context "where the trainee is associated with another provider" do
        let(:trainee) { create(:trainee) }

        it { is_expected.not_to contain_exactly(trainee) }
      end
    end

    context "system_admin user" do
      let(:trainee) { create(:trainee, :discarded) }
      let(:organisation) { nil }
      let(:is_system_admin?) { true }

      it { is_expected.to contain_exactly(trainee) }
    end
  end
end

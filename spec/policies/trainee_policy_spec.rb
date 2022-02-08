# frozen_string_literal: true

require "rails_helper"

describe TraineePolicy do
  let(:system_admin_user) { create(:user, :system_admin) }
  let(:provider) { create(:provider) }
  let(:other_provider) { create(:provider) }
  let(:provider_user) { user_with_organisation(create(:user, providers: [provider]), provider) }
  let(:other_provider_user) { user_with_organisation(create(:user, providers: [other_provider]), other_provider) }
  let(:lead_school) { create(:school, :lead) }
  let(:lead_school_user) { user_with_organisation(create(:user, providers: []), lead_school) }
  let(:other_lead_school_user) { user_with_organisation(create(:user, providers: []), create(:school, :lead)) }

  let(:provider_trainee) { create(:trainee, provider: provider) }
  let(:lead_school_trainee) { create(:trainee, lead_school: lead_school) }

  subject { described_class }

  def user_with_organisation(user, organisation)
    UserWithOrganisationContext.new(user: user, session: {}).tap do |user_with_org|
      allow(user_with_org).to receive(:organisation).and_return(organisation)
    end
  end

  permissions :show?, :index? do
    it { is_expected.to permit(provider_user, provider_trainee) }
    it { is_expected.to permit(lead_school_user, lead_school_trainee) }

    it { is_expected.to permit(system_admin_user, provider_trainee) }
    it { is_expected.to permit(system_admin_user, lead_school_trainee) }

    it { is_expected.not_to permit(other_provider_user, provider_trainee) }
  end

  permissions :create?, :update?, :edit?, :new?, :destroy?, :confirm? do
    it { is_expected.to permit(provider_user, provider_trainee) }
    it { is_expected.not_to permit(lead_school_user, lead_school_trainee) }

    it { is_expected.to permit(system_admin_user, provider_trainee) }
    it { is_expected.to permit(system_admin_user, lead_school_trainee) }

    it { is_expected.not_to permit(other_provider_user, provider_trainee) }
  end

  permissions :withdraw? do
    context "when trainee is deferred?" do
      before do
        allow(provider_trainee).to receive(:deferred?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is submitted_for_trn?" do
      before do
        allow(provider_trainee).to receive(:submitted_for_trn?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is trn_received?" do
      before do
        allow(provider_trainee).to receive(:trn_received?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is recommended" do
      before do
        allow(provider_trainee).to receive(:recommended_for_award?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end
  end

  permissions :defer? do
    context "when trainee is deferred?" do
      before do
        allow(provider_trainee).to receive(:deferred?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is submitted_for_trn?" do
      before do
        allow(provider_trainee).to receive(:submitted_for_trn?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is trn_received?" do
      before do
        allow(provider_trainee).to receive(:trn_received?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is recommended" do
      before do
        allow(provider_trainee).to receive(:recommended_for_award?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end
  end

  permissions :reinstate? do
    context "when trainee is deferred?" do
      before do
        allow(provider_trainee).to receive(:deferred?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is recommended" do
      before do
        allow(provider_trainee).to receive(:recommended_for_award?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end
  end

  permissions :recommended? do
    context "when trainee is recommended" do
      before do
        allow(provider_trainee).to receive(:recommended_for_award?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is deferred?" do
      before do
        allow(provider_trainee).to receive(:deferred?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end
  end

  permissions :recommend_for_award? do
    context "when trainee is trn_received?" do
      before do
        allow(provider_trainee).to receive(:trn_received?).and_return(true)
      end

      it { is_expected.to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.to permit(system_admin_user, provider_trainee) }
    end

    context "when trainee is recommended_for_award?" do
      before do
        allow(provider_trainee).to receive(:recommended_for_award?).and_return(true)
      end

      it { is_expected.not_to permit(provider_user, provider_trainee) }
      it { is_expected.not_to permit(other_provider_user, provider_trainee) }
      it { is_expected.not_to permit(lead_school_user, provider_trainee) }
      it { is_expected.not_to permit(system_admin_user, provider_trainee) }
    end
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

# frozen_string_literal: true

require "rails_helper"

describe TraineePolicy do
  let(:provider) { create(:provider) }
  let(:provider_user) { build(:user, provider: provider) }
  let(:other_provider_user) { build(:user) }
  let(:trainee) { create(:trainee, provider: provider) }

  subject { described_class }

  permissions :show?, :create?, :update? do
    it { is_expected.to permit(provider_user, trainee) }
    it { is_expected.not_to permit(other_provider_user, trainee) }
  end

  describe TraineePolicy::Scope do
    let(:user) { create(:user, provider: provider) }
    let(:provider) { create(:provider) }

    subject { described_class.new(user, Trainee.all).resolve }

    context "trainees belonging to the user's provider" do
      let(:trainee) { create(:trainee, provider: provider) }

      it { is_expected.to contain_exactly(trainee) }
    end

    context "trainees not belonging to the user's provider" do
      let(:trainee) { create(:trainee) }

      it { is_expected.not_to contain_exactly(trainee) }
    end
  end
end

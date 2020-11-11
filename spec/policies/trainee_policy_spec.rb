require "rails_helper"

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

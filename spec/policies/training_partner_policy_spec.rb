# frozen_string_literal: true

require "rails_helper"

describe TrainingPartnerPolicy do
  let(:system_admin_user) { build(:user, :system_admin) }
  let(:other_user) { create(:user) }

  subject { described_class }

  permissions :index?, :show?, :new?, :create? do
    it { is_expected.to permit(system_admin_user) }
    it { is_expected.not_to permit(other_user) }
  end

  describe TrainingPartnerPolicy::Scope do
    let!(:hei_training_partner) { create(:training_partner, :hei, name: "AAA") }
    let!(:school_training_partner) { create(:training_partner, :school, name: "BBB") }

    subject { described_class.new(user, TrainingPartner).resolve }

    context "ordered by name" do
      let(:user) { system_admin_user }

      it { expect(subject.size).to be(2) }
      it { expect(subject[0]).to eq(hei_training_partner) }
      it { expect(subject[1]).to eq(school_training_partner) }
    end
  end
end

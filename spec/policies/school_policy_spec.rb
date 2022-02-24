# frozen_string_literal: true

require "rails_helper"

describe SchoolPolicy do
  let(:system_admin_user) { build(:user, :system_admin) }
  let(:other_user) { create(:user) }

  subject { described_class }

  permissions :index?, :show?, :new?, :create? do
    it { is_expected.to permit(system_admin_user) }
    it { is_expected.not_to permit(other_user) }
  end

  describe SchoolPolicy::Scope do
    let!(:school1) { create(:school, name: "AAA") }
    let!(:school2) { create(:school, name: "BBB") }
    let(:user) { system_admin_user }

    subject { described_class.new(user, School).resolve }

    it { expect(subject).to match_array([school1, school2]) }
  end
end

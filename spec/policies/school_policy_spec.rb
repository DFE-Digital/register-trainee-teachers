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

    subject { described_class.new(user, School).resolve }

    context "ordered by name" do
      let(:user) { system_admin_user }
      let(:trainee) { create(:trainee, :discarded) }

      it { expect(subject[0]).to eql(school1) }
      it { expect(subject[1]).to eql(school2) }
    end
  end
end

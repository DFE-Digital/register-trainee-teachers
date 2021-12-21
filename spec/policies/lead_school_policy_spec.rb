# frozen_string_literal: true

require "rails_helper"

describe LeadSchoolPolicy do
  let(:system_admin_user) { build(:user, :system_admin) }
  let(:other_user) { create(:user) }

  subject { described_class }

  permissions :index?, :show?, :new?, :create? do
    it { is_expected.to permit(system_admin_user) }
    it { is_expected.not_to permit(other_user) }
  end

  describe LeadSchoolPolicy::Scope do
    let!(:lead_school1) { create(:school, :lead, name: "AAA") }
    let!(:lead_school2) { create(:school, :lead, name: "BBB") }
    let!(:non_lead_school) { create(:school, name: "TEST", lead_school: false) }

    subject { described_class.new(user, School).resolve }

    context "ordered by name" do
      let(:user) { system_admin_user }

      it { expect(subject[0]).to eql(lead_school1) }
      it { expect(subject[1]).to eql(lead_school2) }
      it { expect(subject.to_a).not_to include(non_lead_school) }
    end
  end
end

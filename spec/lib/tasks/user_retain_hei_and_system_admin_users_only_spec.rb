# frozen_string_literal: true

require "rails_helper"

describe "user:retain_hei_and_system_admin_users_only" do
  subject do
    Rake::Task["user:retain_hei_and_system_admin_users_only"].execute
  end

  let(:active_hei_provider) { create(:provider, :hei) }
  let(:system_admin_user) { create(:user, :system_admin) }
  let(:user_with_no_provider) { create(:user, providers: []) }

  let(:inactive_hei_provider) { create(:provider, :hei) }
  let(:unaccredited_hei_provider) { create(:provider, :hei, :unaccredited) }
  let(:active_scitt_provider) { create(:provider, :scitt) }
  let(:inactive_scitt_provider) { create(:provider, :scitt) }
  let(:unaccredited_scitt_provider) { create(:provider, :scitt, :unaccredited) }

  let(:lead_partner_user_hei) { create(:lead_partner_user, lead_partner: build(:lead_partner, :hei)) }
  let(:lead_partner_user_school) { create(:lead_partner_user, lead_partner: build(:lead_partner, :school)) }
  let(:lead_partner_user_scitt) { create(:lead_partner_user, lead_partner: build(:lead_partner, :scitt)) }

  before do
    active_hei_provider
    system_admin_user

    user_with_no_provider

    lead_partner_user_hei
    lead_partner_user_school
    lead_partner_user_scitt

    inactive_hei_provider.discard
    unaccredited_hei_provider

    active_scitt_provider
    inactive_scitt_provider.discard
    unaccredited_scitt_provider
  end

  it "retains HEI and system admin users only" do
    subject

    expect(active_hei_provider.users.reload.pluck(:dfe_sign_in_uid).compact).not_to be_blank
    expect(system_admin_user.reload.dfe_sign_in_uid).not_to be_blank

    expect(user_with_no_provider.reload.dfe_sign_in_uid).to be_blank

    expect(lead_partner_user_hei.user.reload.dfe_sign_in_uid).to be_blank
    expect(lead_partner_user_school.user.reload.dfe_sign_in_uid).to be_blank
    expect(lead_partner_user_scitt.user.reload.dfe_sign_in_uid).to be_blank

    expect(LeadPartnerUser.all.reload.count).to be_zero
    expect(ProviderUser.all.reload.count).to eq(1)

    expect(inactive_hei_provider.users.reload.pluck(:dfe_sign_in_uid).compact).to be_blank
    expect(unaccredited_hei_provider.users.reload.pluck(:dfe_sign_in_uid).compact).to be_blank

    expect(active_scitt_provider.users.reload.pluck(:dfe_sign_in_uid).compact).to be_blank
    expect(inactive_scitt_provider.users.reload.pluck(:dfe_sign_in_uid).compact).to be_blank
    expect(unaccredited_scitt_provider.users.reload.pluck(:dfe_sign_in_uid).compact).to be_blank

    expect(Provider.all.reload.with_active_hei.count).to eq(1)
    expect(User.all.reload.pluck(:dfe_sign_in_uid).compact.count).to eq(2)
  end
end

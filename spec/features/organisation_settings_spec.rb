# frozen_string_literal: true

require "rails_helper"

feature "Organisation details" do
  before do
    given_i_am_authenticated(user:)
  end

  context "when a User belongs to a Provider organisation" do
    let(:provider) { create(:provider) }
    let(:user) { create(:user, providers: [provider]) }

    let!(:provider_user_one) { create(:user, providers: [provider]) }
    let!(:provider_user_two) { create(:user, providers: [provider]) }
    let!(:other_provider_user) { create(:user) }

    scenario "a user views the organisation settings page" do
      organisation_settings_page.settings_link.click

      expect(organisation_settings_page).to have_content(provider.name)
      expect(organisation_settings_page).to have_content("About your organisation")
      expect(organisation_settings_page).to have_content("Organisation typeAccredited provider")

      expect(organisation_settings_page).to have_content("Accreditation ID#{provider.accreditation_id}")
      expect(organisation_settings_page).to have_content("Team members")

      expect(organisation_settings_page).to have_content("#{user.name}(you) – #{user.email}")
      expect(organisation_settings_page).to have_content("#{provider_user_one.name} – #{provider_user_one.email}")
      expect(organisation_settings_page).to have_content("#{provider_user_two.name} – #{provider_user_two.email}")
      expect(organisation_settings_page).not_to have_content("#{other_provider_user.name} – #{other_provider_user.email}")

      expect(organisation_settings_page).to have_content(
        "If you need to add or remove team members, contact us at becomingateacher@digital.education.gov.uk.",
      )
    end
  end

  context "when a User belongs to a Lead Partner organisation" do
    let(:lead_partner) { create(:lead_partner, :hei) }
    let(:user) { create(:user, lead_partners: [lead_partner]) }

    let!(:lead_partner_user_one) { create(:user, lead_partners: [lead_partner]) }
    let!(:lead_partner_user_two) { create(:user, lead_partners: [lead_partner]) }
    let!(:other_lead_partner_user) { create(:user, :with_lead_partner_organisation) }

    scenario "a user views the organisation settings page" do
      click_on lead_partner.name

      organisation_settings_page.settings_link.click

      expect(organisation_settings_page).to have_content(lead_partner.name)
      expect(organisation_settings_page).to have_content("About your organisation")
      expect(organisation_settings_page).to have_content("Organisation typeLead partner")

      expect(organisation_settings_page).to have_content("Accreditation ID#{lead_partner.accreditation_id}")
      expect(organisation_settings_page).to have_content("Team members")

      expect(organisation_settings_page).to have_content("#{user.name}(you) – #{user.email}")
      expect(organisation_settings_page).to have_content("#{lead_partner_user_one.name} – #{lead_partner_user_one.email}")
      expect(organisation_settings_page).to have_content("#{lead_partner_user_two.name} – #{lead_partner_user_two.email}")
      expect(organisation_settings_page).not_to have_content("#{other_lead_partner_user.name} – #{other_lead_partner_user.email}")

      expect(organisation_settings_page).to have_content(
        "If you need to add or remove team members, contact us at becomingateacher@digital.education.gov.uk.",
      )
    end
  end

  context "when a user is a system admin with no organisation" do
    let(:user) { create(:user, :system_admin) }

    scenario "a user attempts to view the organisation settings page" do
      expect(page).not_to have_link("Organisation settings")

      organisation_settings_page.load

      expect(page).to have_content(
        "You do not have permission to perform this action",
      )
    end
  end
end

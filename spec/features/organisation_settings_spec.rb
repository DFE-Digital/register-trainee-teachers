# frozen_string_literal: true

require "rails_helper"

feature "Organisation details" do
  before do
    given_i_am_authenticated(user:)
  end

  context "when a User belongs to a Provider organisation" do
    let(:organisation) { create(:provider) }
    let(:user) { create(:user, providers: [organisation]) }

    let!(:user_one) { create(:user, providers: [organisation]) }
    let!(:user_two) { create(:user, providers: [organisation]) }
    let!(:user_three) { create(:user) }

    scenario "a user views the organisation settings page" do
      when_i_click_on_the_organisation_settings_link
      then_i_see_the_organisation_details
      and_i_see_the_organisation_team_members
      and_i_see_the_contact_support_email
    end
  end

  context "when a User belongs to a Lead Partner organisation" do
    let(:organisation) { create(:lead_partner, :hei) }
    let(:user) { create(:user, lead_partners: [organisation]) }

    let!(:user_one) { create(:user, lead_partners: [organisation]) }
    let!(:user_two) { create(:user, lead_partners: [organisation]) }
    let!(:user_three) { create(:user, :with_lead_partner_organisation) }

    before do
      give_i_have_clicked_on_the_organisation_name_link
    end

    scenario "a user views the organisation settings page" do
      when_i_click_on_the_organisation_settings_link
      then_i_see_the_organisation_details
      and_i_see_the_organisation_team_members
      and_i_see_the_contact_support_email
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

  private

  def give_i_have_clicked_on_the_organisation_name_link
    click_on organisation.name
  end

  def when_i_click_on_the_organisation_settings_link
    organisation_settings_page.settings_link.click
  end

  def then_i_see_the_organisation_details
    expect(organisation_settings_page).to have_content(organisation.name)
    expect(organisation_settings_page).to have_content("About your organisation")
    expect(organisation_settings_page).to have_content(
      "Organisation type#{organisation.is_a?(Provider) ? 'Accredited provider' : 'Lead partner'}"
    )
    expect(organisation_settings_page).to have_content("Accreditation ID#{organisation.accreditation_id}")
  end

  def and_i_see_the_organisation_team_members
    expect(organisation_settings_page).to have_content("Team members")
    expect(organisation_settings_page).to have_content("#{current_user.name}(you) – #{current_user.email}")
    expect(organisation_settings_page).to have_content("#{user_one.name} – #{user_one.email}")
    expect(organisation_settings_page).to have_content("#{user_two.name} – #{user_two.email}")
    expect(organisation_settings_page).not_to have_content("#{user_three.name} – #{user_three.email}")
  end

  def and_i_see_the_contact_support_email
    expect(organisation_settings_page).to have_content(
      "If you need to add or remove team members, contact us at becomingateacher@digital.education.gov.uk.",
    )
  end
end

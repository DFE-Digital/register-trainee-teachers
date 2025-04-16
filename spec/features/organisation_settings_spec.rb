# frozen_string_literal: true

require "rails_helper"

feature "Organisation details" do
  before do
    given_i_am_authenticated(user:)
  end

  let!(:token_four) { create(:authentication_token, :revoked, provider: provider, name: "Token 4", created_by: user) }
  let!(:token_two) { create(:authentication_token, :will_expire, name: "Token 2", provider: provider, created_by: user, last_used_at: 1.day.ago) }
  let!(:token_one) { create(:authentication_token, name: "Token 1", provider: provider, created_by: user) }
  let!(:token_three) { create(:authentication_token, :expired, provider: provider, name: "Token 3", created_by: user) }
  let!(:token_five) { create(:authentication_token, name: "Token 5", created_by: user) }

  context "when a User belongs to a Provider organisation" do
    let(:accreditation_id) { Faker::Number.unique.number(digits: 4) }
    let(:organisation) { create(:provider, accreditation_id:) }
    let(:user) { create(:user, providers: [organisation]) }
    let(:provider) { organisation }

    let!(:user_one) { create(:user, providers: [organisation]) }
    let!(:user_two) { create(:user, providers: [organisation]) }
    let!(:user_three) { create(:user) }
    let!(:discarded_user) { create(:user, providers: [organisation], discarded_at: 1.day.ago) }

    scenario "a user views the organisation settings page" do
      when_i_click_on_the_organisation_settings_link
      then_i_see_the_organisation_details
      and_i_see_the_organisation_team_members
      and_i_see_the_contact_support_email
      and_i_dont_see_api_tokens_details

      when_i_click_on_back_link
      then_i_see_the_root_page
    end

    scenario "a user views the token management page", feature_token_management: true, js: true do
      when_i_click_on_the_organisation_settings_link
      and_i_see_api_tokens_details

      and_i_click_on_view_docs_link do |window|
        then_i_see_the_documentation(window)
      end

      when_i_click_on_manage_your_tokens_link
      then_i_see_the_token_management_page

      when_i_click_on_back_link
      and_i_see_api_tokens_details
    end
  end

  context "when a User belongs to a Lead Partner organisation" do
    let(:accreditation_id) { nil }
    let(:organisation) { create(:lead_partner, :hei) }
    let(:user) { create(:user, lead_partners: [organisation]) }
    let!(:provider) { organisation.provider }

    let!(:user_one) { create(:user, lead_partners: [organisation]) }
    let!(:user_two) { create(:user, lead_partners: [organisation]) }
    let!(:user_three) { create(:user, :with_lead_partner_organisation) }
    let!(:discarded_user) { create(:user, lead_partners: [organisation], discarded_at: 1.day.ago) }

    before do
      given_i_have_clicked_on_the_organisation_name_link
    end

    scenario "a user views the organisation settings page" do
      when_i_click_on_the_organisation_settings_link
      then_i_see_the_organisation_details
      and_i_see_the_organisation_team_members
      and_i_see_the_contact_support_email
      and_i_dont_see_api_tokens_details
    end

    scenario "a user views the token management page", feature_token_management: true, js: true do
      when_i_click_on_the_organisation_settings_link
      then_i_dont_see_api_tokens_details

      when_i_attempt_to_visit_the_token_management_page
      then_i_see_the_unauthorized_message
    end
  end

  context "when a user is a system admin with no organisation" do
    let(:user) { create(:user, :system_admin) }
    let(:provider) { create(:provider) }

    scenario "a user attempts to view the organisation settings page" do
      given_the_organisation_settings_link_is_not_visible
      when_i_attempt_to_visit_the_organisation_settings_page
      then_i_see_the_unauthorized_message
    end

    scenario "a user attempts to view the token management page", feature_token_management: true do
      when_i_attempt_to_visit_the_token_management_page
      then_i_see_the_unauthorized_message
    end
  end

private

  def given_the_organisation_settings_link_is_not_visible
    expect(page).not_to have_link("Organisation settings")
  end

  def given_i_have_clicked_on_the_organisation_name_link
    click_on organisation.name
  end

  def when_i_attempt_to_visit_the_organisation_settings_page
    organisation_settings_page.load
  end

  def when_i_click_on_the_organisation_settings_link
    organisation_settings_page.settings_link.click
  end

  def and_i_see_api_tokens_details
    expect(organisation_settings_page).to have_content("Register API Tokens")
    expect(organisation_settings_page).to have_content(
      "You need an API token if you want to use the Register API to send your trainee data from your students record system directly to the Register service.",
    )
    expect(organisation_settings_page).to have_content(
      "The API token is unique to your organisation and is a code that authenticates the transfer of your trainee data from your student record system directly into the Register service.",
    )
    expect(organisation_settings_page).to have_content(
      "Your token is needed by the developers who are managing your Register API integration.",
    )
    expect(organisation_settings_page).to have_content(
      "You can view and use the Register API technical documentation (opens in new tab).",
    )
    expect(organisation_settings_page).to have_content(
      "How to manage your API token",
    )
    expect(organisation_settings_page).to have_content(
      "The Register API is used to make trainee data transfer quicker and easier.",
    )
    expect(organisation_settings_page).to have_content(
      "You must make sure the token is securely sent to the developers managing your Register API integration.",
    )
    expect(organisation_settings_page).to have_content(
      "In the 'Manage your API token' screen, you can:",
    )
    expect(organisation_settings_page).to have_content(
      "view a list of tokens, their description, expiry date, date last used",
    )
    expect(organisation_settings_page).to have_content(
      "generate a new token and give it a name, a description (optional) and set an expiry date (optional) revoke a token",
    )
  end

  def and_i_dont_see_api_tokens_details
    expect(organisation_settings_page).not_to have_content("Register API Tokens")
    expect(organisation_settings_page).not_to have_content(
      "You need an API token if you want to use the Register API to send your trainee data from your students record system directly to the Register service.",
    )
    expect(organisation_settings_page).not_to have_content(
      "The API token is unique to your organisation and is a code that authenticates the transfer of your trainee data from your student record system directly into the Register service.",
    )
    expect(organisation_settings_page).not_to have_content(
      "Your token is needed by the developers who are managing your Register API integration.",
    )
    expect(organisation_settings_page).not_to have_content(
      "You can view and use the Register API technical documentation (opens in new tab).",
    )
    expect(organisation_settings_page).not_to have_content(
      "How to manage your API token",
    )
    expect(organisation_settings_page).not_to have_content(
      "The Register API is used to make trainee data transfer quicker and easier.",
    )
    expect(organisation_settings_page).not_to have_content(
      "You must make sure the token is securely sent to the developers managing your Register API integration.",
    )
    expect(organisation_settings_page).not_to have_content(
      "In the 'Manage your API token' screen, you can:",
    )
    expect(organisation_settings_page).not_to have_content(
      "view a list of tokens, their description, expiry date, date last used",
    )
    expect(organisation_settings_page).not_to have_content(
      "generate a new token and give it a name, a description (optional) and set an expiry date (optional) revoke a token",
    )
  end

  def then_i_see_the_token_management_page
    expect(token_management_page).to have_content("Manage your API tokens")

    expect(token_management_page).to have_content("You can:")

    expect(token_management_page).to have_content(
      "view a list of tokens, their description, expiry date, date last used",
    )

    expect(token_management_page).to have_content(
      "generate a new token, give it a name, set an expiry date (optional) and revoke a token",
    )

    expect(token_management_page).to have_content(
      "These API tokens are unique to your organisation.",
    )

    expect(token_management_page).to have_content(
      "You should let the developers managing your Register API integration know if you create, set an expiry date or revoke a token.",
    )

    expect(token_management_page).to have_content(
      "You must make sure the token is securely sent to the developers managing your Register API integration.",
    )

    expect(token_management_page).to have_content("Previously created tokens")

    token_names = all(".govuk-summary-card__title").map(&:text)

    expect(token_names).to eq(["Token 1", "Token 2", "Token 3", "Token 4"])

    within("#token-#{token_one.id}") do
      expect(token_management_page).to have_content("Token 1")
      expect(token_management_page).to have_content("Status\tActive")
      expect(token_management_page).to have_content("Created by\t#{user.name} on #{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).to have_content("Last used\t#{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).not_to have_content("Revoked by")
      expect(token_management_page).not_to have_content("Expires on")
      expect(token_management_page).not_to have_content("Expired")
    end

    within("#token-#{token_two.id}") do
      expect(token_management_page).to have_content("Token 2")
      expect(token_management_page).to have_content("Status\tActive")
      expect(token_management_page).to have_content("Created by\t#{user.name} on #{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).to have_content("Last used\t#{1.day.ago.to_date.to_fs(:govuk)}")
      expect(token_management_page).not_to have_content("Revoked by")
      expect(token_management_page).to have_content("Expires on\t#{1.month.from_now.to_date.to_fs(:govuk)}")
    end

    within("#token-#{token_three.id}") do
      expect(token_management_page).to have_content("Token 3")
      expect(token_management_page).to have_content("Status\tExpired")
      expect(token_management_page).to have_content("Created by\t#{user.name} on #{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).to have_content("Last used\t#{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).not_to have_content("Revoked by")
      expect(token_management_page).to have_content("Expired\t#{1.day.ago.to_date.to_fs(:govuk)}")
    end

    within("#token-#{token_four.id}") do
      expect(token_management_page).to have_content("Token 4")
      expect(token_management_page).to have_content("Status\tRevoked")
      expect(token_management_page).to have_content("Created by\t#{user.name} on #{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).to have_content("Last used\t#{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).to have_content("Revoked by\t#{user.name} on #{Time.zone.today.to_fs(:govuk)}")
      expect(token_management_page).not_to have_content("Expires on")
      expect(token_management_page).not_to have_content("Expired")
    end

    expect(page).not_to have_css("#token-#{token_five.id}")
  end

  def and_i_click_on_view_docs_link
    original_window = page.current_window
    window = window_opened_by do
      organisation_settings_page.documentation_link.click
    end

    yield window

    window.close

    switch_to_window(original_window)
  end

  def then_i_see_the_documentation(window)
    within_window(window) do
      expect(page).to have_content("Register API reference")
    end
  end

  def when_i_click_on_manage_your_tokens_link
    organisation_settings_page.token_management_link.click
  end

  def then_i_see_the_organisation_details
    expect(organisation_settings_page).to have_content(organisation.name)
    expect(organisation_settings_page).to have_content("About your organisation")
    expect(organisation_settings_page).to have_content(
      "Organisation type#{organisation.is_a?(Provider) ? 'Accredited provider' : 'Lead partner'}",
    )
    expect(organisation_settings_page).to have_content("Accreditation ID#{accreditation_id}")
  end

  def and_i_see_the_organisation_team_members
    expect(organisation_settings_page).to have_content("Team members")
    expect(organisation_settings_page).to have_content("#{current_user.name} (you) – #{current_user.email}")
    expect(organisation_settings_page).to have_content("#{user_one.name} – #{user_one.email}")
    expect(organisation_settings_page).to have_content("#{user_two.name} – #{user_two.email}")
    expect(organisation_settings_page).not_to have_content("#{user_three.name} – #{user_three.email}")
    expect(organisation_settings_page).not_to have_content("#{discarded_user.name} – #{discarded_user.email}")
  end

  def and_i_see_the_contact_support_email
    expect(organisation_settings_page).to have_content(
      "If you need to add or remove team members, contact us at becomingateacher@digital.education.gov.uk.",
    )
  end

  def when_i_click_on_back_link
    organisation_settings_page.back_link.click
  end

  def then_i_see_the_root_page
    expect(page).to have_content("Your trainee teachers")
  end

  def then_i_see_the_unauthorized_message
    expect(page).to have_content("You do not have permission to perform this action")
  end

  def when_i_attempt_to_visit_the_token_management_page
    token_management_page.load
  end

  alias_method :then_i_dont_see_api_tokens_details, :and_i_dont_see_api_tokens_details
end

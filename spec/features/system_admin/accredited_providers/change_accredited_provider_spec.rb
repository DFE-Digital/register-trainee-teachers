# frozen_string_literal: true

require "rails_helper"

feature "Change a trainee's accredited provider" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:trainee) { create(:trainee, :trn_received) }
    let!(:new_provider) { create(:provider) }

    before do
      given_i_am_authenticated(user:)
      and_the_change_accredited_provider_feature_is_not_enabled
    end

    scenario "I can edit a trainee's accredited provider" do
      when_i_visit_the_trainee_detail_page
      then_i_do_not_see_a_change_provider_link

      when_the_change_accredited_provider_feature_is_enabled
      and_i_visit_the_trainee_detail_page
      and_i_click_the_change_provider_link
      then_i_see_the_change_accredited_providers_page

      when_i_select_a_provider
      and_click_continue
      then_i_see_the_reasons_page

      when_i_fill_in_reasons
      and_click_continue
      then_i_see_the_confirmation_page

      when_i_click_update
      then_i_see_a_flash_message
      and_i_see_the_new_provider_name_and_code
    end

    scenario "submit buttons return to correct path from confirmation page" do
      given_i_am_reviewing_my_changes_on_the_confirmation_page
      when_i_click_to_change_the_accredited_provider
      then_i_see_the_change_accredited_providers_page
      when_i_click_continue
      then_i_see_the_confirmation_page

      when_i_click_to_change_the_zendesk_ticket_url
      then_i_see_the_reasons_page
      when_i_click_continue
      then_i_see_the_confirmation_page
    end

    scenario "back links" do
      given_i_am_reviewing_my_changes_on_the_confirmation_page
      when_i_click_to_change_the_accredited_provider
      then_i_see_the_change_accredited_providers_page
      when_i_click_back
      then_i_see_the_confirmation_page

      when_i_click_to_change_the_zendesk_ticket_url
      then_i_see_the_reasons_page
      when_i_click_back
      then_i_see_the_confirmation_page

      when_i_click_update
      and_i_click_the_change_provider_link
      and_i_click_back
      then_i_see_the_trainee_detail_page
    end
  end

  def and_the_change_accredited_provider_feature_is_not_enabled
    disable_features(:change_accredited_provider)
  end

  def when_the_change_accredited_provider_feature_is_enabled
    enable_features(:change_accredited_provider)
  end

  def when_i_visit_the_trainee_detail_page
    visit "/trainees/#{trainee.slug}"
  end
  alias_method :and_i_visit_the_trainee_detail_page, :when_i_visit_the_trainee_detail_page

  def then_i_do_not_see_a_change_provider_link
    within ".govuk-summary-list__row.accrediting-provider" do
      expect(page).not_to have_link("Change")
    end
  end

  def and_i_click_the_change_provider_link
    within ".govuk-summary-list__row.accrediting-provider" do
      click_link "Change"
    end
  end

  def then_i_see_the_change_accredited_providers_page
    expect(page).to have_content("Change accredited provider")
  end

  def when_i_select_a_provider
    select new_provider.name, from: "system-admin-change-accredited-provider-form-accredited-provider-id-field"
  end

  def and_click_continue
    click_button "Continue"
  end
  alias_method :when_i_click_continue, :and_click_continue

  def then_i_see_the_reasons_page
    expect(page).to have_content("Why you’re changing the accredited provider")
  end

  def when_i_fill_in_reasons
    fill_in(
      "system-admin-change-accredited-provider-form-audit-comment-field",
      with: "Provider has cancelled this course",
    )
    fill_in(
      "system-admin-change-accredited-provider-form-zendesk-ticket-url-field",
      with: "https://becomingateacher.zendesk.com/agent/tickets/12345",
    )
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Check change of accredited provider details")
  end

  def when_i_click_update
    click_button "Update"
  end

  def then_i_see_a_flash_message
    within ".govuk-notification-banner--success" do
      expect(page).to have_content("Accredited provider changed")
    end
  end

  def and_i_see_the_new_provider_name_and_code
    expect(page).to have_content(new_provider.name_and_code)
  end

  def given_i_am_reviewing_my_changes_on_the_confirmation_page
    when_i_visit_the_trainee_detail_page
    then_i_do_not_see_a_change_provider_link

    when_the_change_accredited_provider_feature_is_enabled
    and_i_visit_the_trainee_detail_page
    and_i_click_the_change_provider_link
    then_i_see_the_change_accredited_providers_page

    when_i_select_a_provider
    and_click_continue
    then_i_see_the_reasons_page

    when_i_fill_in_reasons
    and_click_continue
    then_i_see_the_confirmation_page
  end

  def when_i_click_to_change_the_accredited_provider
    click_link "Change accredited provider"
  end

  def when_i_click_to_change_the_zendesk_ticket_url
    click_link "Change zendesk ticket url"
  end

  def when_i_click_back
    click_link "Back"
  end
  alias_method :and_i_click_back, :when_i_click_back

  def then_i_see_the_trainee_detail_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}", ignore_query: true)
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "Change a trainee's accredited provider" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let(:trainee) { create(:trainee, :trn_received) }
    let!(:new_provider) { create(:provider) }

    before do
      given_i_am_authenticated(user:)
      and_the_change_accredited_provider_feature_is_enabled
    end

    scenario "i can edit a trainee's accredited provider" do
      when_i_visit_the_trainee_detail_page
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
  end

  def and_the_change_accredited_provider_feature_is_enabled
    enable_features(:change_accredited_provider)
  end

  def when_i_visit_the_trainee_detail_page
    visit "/trainees/#{trainee.slug}"
  end

  def and_i_click_the_change_provider_link
    within ".govuk-summary-list__row.accrediting-provider" do
      click_on "Change"
    end
  end

  def then_i_see_the_change_accredited_providers_page
    expect(page).to have_content("Change accredited provider")
  end

  def when_i_select_a_provider
    select new_provider.name, from: "system-admin-change-accredited-provider-form-accredited-provider-id-field"
  end

  def and_click_continue
    click_on "Continue"
  end

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
    click_on "Update"
  end

  def then_i_see_a_flash_message
    within ".govuk-notification-banner--success" do
      expect(page).to have_content("Accredited provider changed")
    end
  end

  def and_i_see_the_new_provider_name_and_code
    expect(page).to have_content(new_provider.name_and_code)
  end
end

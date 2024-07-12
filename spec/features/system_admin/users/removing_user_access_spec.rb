# frozen_string_literal: true

require "rails_helper"

feature "Removing user access" do
  let(:user) { create(:user, :with_multiple_organisations, system_admin: true) }

  before do
    given_i_am_authenticated(user:)
  end

  scenario "provider" do
    given_i_am_on_a_user_page
    and_the_provider_access_table_is_shown
    and_i_choose_a_user_to_remove_access_under_providers
    and_i_confirm_remove_access_from_provider
    then_the_provider_is_no_longer_listed_on_the_user_page
  end

  scenario "lead partner" do
    given_i_am_on_a_user_page
    and_the_lead_school_access_table_is_shown
    and_i_choose_a_user_to_remove_access_under_lead_schools
    and_i_confirm_remove_access_from_lead_school
    then_the_lead_school_is_no_longer_listed_on_the_user_page
  end

private

  def given_i_am_on_a_user_page
    admin_user_show_page.load(id: user.id)
  end

  def and_the_provider_access_table_is_shown
    expect(admin_user_show_page).to have_content(user.providers.first.name)
  end

  def and_the_lead_school_access_table_is_shown
    expect(admin_user_show_page).to have_content(user.lead_schools.first.name)
  end

  def and_i_choose_a_user_to_remove_access_under_providers
    admin_user_show_page.providers.remove_access_links.first.click
  end

  def and_i_choose_a_user_to_remove_access_under_lead_schools
    admin_user_show_page.lead_schools.remove_access_links.first.click
  end

  def and_i_confirm_remove_access_from_provider
    admin_remove_provider_access_page.submit.click
  end

  def and_i_confirm_remove_access_from_lead_school
    admin_remove_lead_school_access_page.submit.click
  end

  def then_the_provider_is_no_longer_listed_on_the_user_page
    expect(admin_user_show_page).not_to have_content(user.providers.first.name)
    expect(admin_user_show_page.flash_message).to be_visible
  end

  def then_the_lead_school_is_no_longer_listed_on_the_user_page
    expect(admin_user_show_page).not_to have_content(user.lead_schools.first.name)
    expect(admin_user_show_page.flash_message).to be_visible
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "Search users" do
  context "as a system admin" do
    let(:user) { create(:user, system_admin: true) }
    let!(:second_user) { create(:user, system_admin: true) }

    before do
      given_i_am_authenticated(user:)
    end

    scenario "search users" do
      when_i_visit_the_user_index_page
      then_i_see_the_users
      then_i_enter_the_first_users_last_name_into_the_search_field
      then_i_click_search
      then_i_see_only_the_first_user
      then_i_enter_the_second_users_email_address_into_the_search_field
      then_i_click_search
      then_i_see_only_the_second_user
    end
  end

  context "as a system admin with JavaScript", js: true do
    let(:user) { create(:user, first_name: "Bob", system_admin: true) }
    let!(:second_user) { create(:user, first_name: "Alice") }
    let(:provider) { create(:provider, name: "West Pudding University") }
    let(:lead_partner) { create(:lead_partner, :school, name: "East Porridge School") }

    before do
      second_user.providers << provider
      second_user.lead_partners << lead_partner
      given_i_am_authenticated(user:)
    end

    scenario "search users by name" do
      when_i_visit_the_user_index_page
      then_i_see_the_users
      when_i_enter_the_first_users_last_name_into_the_autocomplete
      and_click_on_the_first_user_in_the_autocomplete
      then_i_see_the_detail_page_for_the_second_user
    end

    scenario "search users by training partner name" do
      when_i_visit_the_user_index_page
      when_i_enter_the_first_users_lead_partner_name_into_the_autocomplete
      and_click_on_the_first_user_in_the_autocomplete
      then_i_see_the_detail_page_for_the_second_user
    end

    scenario "search users by provider name" do
      when_i_visit_the_user_index_page
      when_i_enter_the_first_users_provider_name_into_the_autocomplete
      and_click_on_the_first_user_in_the_autocomplete
      then_i_see_the_detail_page_for_the_second_user
    end
  end

  def when_i_enter_the_first_users_last_name_into_the_autocomplete
    fill_in("search-field", with: second_user.last_name)
  end

  def when_i_enter_the_first_users_lead_partner_name_into_the_autocomplete
    fill_in("search-field", with: "East Porridge")
  end

  def when_i_enter_the_first_users_provider_name_into_the_autocomplete
    fill_in("search-field", with: "West Pudding")
  end

  def and_click_on_the_first_user_in_the_autocomplete
    find("#search-field__listbox li:first-child").click
  end

  def then_i_see_the_detail_page_for_the_second_user
    expect(page).to have_current_path(user_path(second_user))
  end

  def when_i_visit_the_user_index_page
    admin_users_index_page.load
  end

  def then_i_see_the_users
    index_page_has_first_user_details
    index_page_has_second_user_details
  end

  def index_page_has_first_user_details
    expect(admin_users_index_page).to have_text(user.first_name)
    expect(admin_users_index_page).to have_text(user.last_name)
    expect(admin_users_index_page).to have_text(user.email)
  end

  def index_page_has_second_user_details
    expect(admin_users_index_page).to have_text(second_user.first_name)
    expect(admin_users_index_page).to have_text(second_user.last_name)
    expect(admin_users_index_page).to have_text(second_user.email)
  end

  def then_i_enter_the_first_users_last_name_into_the_search_field
    admin_users_index_page.search.set(user.last_name)
  end

  def then_i_click_search
    admin_users_index_page.submit_search.click
  end

  def then_i_see_only_the_first_user
    index_page_has_first_user_details
    expect(admin_users_index_page).not_to have_text(second_user.first_name)
  end

  def then_i_enter_the_second_users_email_address_into_the_search_field
    admin_users_index_page.search.set(second_user.email)
  end

  def then_i_see_only_the_second_user
    index_page_has_second_user_details
    expect(admin_users_index_page).not_to have_text(user.first_name)
  end
end

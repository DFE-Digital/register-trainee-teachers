# frozen_string_literal: true

require "rails_helper"

feature "create a new authentication token" do
  background do
    given_i_am_authenticated
    and_i_can_generate_an_authentication_token
  end

  let(:invalid_expires_at) { Date.new(Date.current.year - 1, 12, 31) }
  let(:expires_at) { Date.new(Date.current.year + 1, 12, 31) }

  scenario "when the feature flag is off I cannot access the create token form", feature_token_management: false do
    given_i_am_authenticated
    and_i_can_generate_an_authentication_token

    when_i_navigate_to_the_create_authentication_token_page
    then_i_see_a_not_found_message
  end

  scenario "when I am logged in as a lead partner the feature flag is on I CANNOT create a token", feature_token_management: true do
    given_i_am_authenticated_as_a_lead_partner_user
    and_i_can_generate_an_authentication_token

    given_i_navigate_to_the_authentication_token_index_page
    then_i_see_an_unauthorised_message
    and_i_cannot_see_the_generate_new_token_button
  end

  scenario "when I am logged in as a system admin the feature flag is on I CANNOT create a token", feature_token_management: true do
    given_i_am_authenticated_as_system_admin
    and_i_can_generate_an_authentication_token

    given_i_navigate_to_the_authentication_token_index_page
    then_i_see_an_unauthorised_message
    and_i_cannot_see_the_generate_new_token_button
  end

  scenario "when the feature flag is on I can create a token", feature_token_management: true do
    given_i_am_authenticated
    and_i_can_generate_an_authentication_token

    given_i_navigate_to_the_authentication_token_index_page
    and_i_click_the_generate_new_token_button
    then_i_should_see_the_new_token_form

    and_i_enter_an_expiry_date_in_the_past
    and_i_click_the_submit_button
    then_i_should_see_validation_error_messages

    when_i_fill_in_the_form_with_valid_data
    and_i_click_the_submit_button
    then_i_should_see_the_new_token_confirmation_page

    when_i_refresh_the_page
    then_i_can_no_longer_see_the_token

    when_i_click_the_continue_to_manage_tokens_button
    then_i_should_see_the_new_token_in_the_list
  end

private

  def when_i_navigate_to_the_create_authentication_token_page
    visit new_authentication_token_path
  end

  def then_i_see_a_not_found_message
    expect(page).to have_content("Page not found")
  end

  def and_i_can_generate_an_authentication_token
    @token_string = "1a2b3c4d5e"
    allow(SecureRandom).to receive(:hex).with(10).and_return(@token_string)
  end

  def given_i_navigate_to_the_authentication_token_index_page
    visit authentication_tokens_path
  end

  def and_i_click_the_generate_new_token_button
    click_on "Generate a new token"
  end

  def then_i_should_see_the_new_token_form
    expect(page).to have_content("Create a token")
  end

  def and_i_enter_an_expiry_date_in_the_past
    fill_in "Day", with: invalid_expires_at.day.to_s
    fill_in "Month", with: invalid_expires_at.month.to_s
    fill_in "Year", with: invalid_expires_at.year.to_s
  end

  def then_i_should_see_validation_error_messages
    expect(page).to have_content("Create a token")
    expect(page).to have_content("There is a problem")
    expect(page).to have_content("Enter the token name")
    expect(page).to have_content("Must be in the future")
  end

  def when_i_fill_in_the_form_with_valid_data
    fill_in "Token name", with: "My new token"
    fill_in "Day", with: expires_at.day.to_s
    fill_in "Month", with: expires_at.month.to_s
    fill_in "Year", with: expires_at.year.to_s
  end

  def and_i_click_the_submit_button
    click_on "Generate token"
  end

  def then_i_should_see_the_new_token_confirmation_page
    expect(page).to have_content("Token generated")
    expect(page).to have_content("Your API token is")
    expect(page).to have_content("test_#{@token_string}")
  end

  def when_i_refresh_the_page
    visit current_path
  end

  def then_i_can_no_longer_see_the_token
    expect(page).not_to have_content("test_#{@token_string}")
  end

  def when_i_click_the_continue_to_manage_tokens_button
    click_on "Continue to manage tokens"
  end

  def then_i_should_see_the_new_token_in_the_list
    expect(page).to have_content("My new token")
  end

  def then_i_see_an_unauthorised_message
    expect(page).to have_content("You do not have permission to perform this action")
  end

  def and_i_cannot_see_the_generate_new_token_button
    expect(page).not_to have_button("Generate a new token")
  end
end

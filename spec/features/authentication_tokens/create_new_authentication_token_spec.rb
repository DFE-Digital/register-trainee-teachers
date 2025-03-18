# frozen_string_literal: true

require "rails_helper"

feature "create a new authentication token" do
  background do
    given_i_am_authenticated
    and_the_authentication_tokens_feature_flag_is_enabled
    and_i_can_generate_an_authentication_token
  end

  let(:expires_at) { Date.new(Date.current.year + 1, 12, 31) }

  scenario "create a token" do
    # TODO: Navigate from the authentication tokens index page to the new page

    given_i_navigate_to_the_new_authentication_token_page
    and_i_fill_in_the_form_with_valid_data
    and_i_click_the_submit_button
    then_i_should_see_the_new_token_confirmation_page

    when_i_click_the_copy_token_button
    then_the_token_should_be_copied_to_my_clipboard

    when_i_refresh_the_page
    then_i_can_no_longer_see_the_token
  end

private

  def and_the_authentication_tokens_feature_flag_is_enabled; end

  def and_i_can_generate_an_authentication_token
    @token_string = "1a2b3c4d5e"
    allow(SecureRandom).to receive(:hex).with(10).and_return(@token_string)
  end

  def given_i_navigate_to_the_new_authentication_token_page
    visit new_authentication_token_path
  end

  def and_i_fill_in_the_form_with_valid_data
    fill_in "Token name", with: "My new token"
    fill_in "authentication_token_expires_at_3i", with: "31"
    fill_in "authentication_token_expires_at_2i", with: "12"
    fill_in "authentication_token_expires_at_1i", with: expires_at.year.to_s
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

  def when_i_click_the_copy_token_button; end

  def then_the_token_should_be_copied_to_my_clipboard; end
end

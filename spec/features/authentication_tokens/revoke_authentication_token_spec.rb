# frozen_string_literal: true

require "rails_helper"

feature "revoke an authentication token" do
  scenario "when the feature flag is on I can revoke a token", feature_token_management: true do
    given_i_am_authenticated_as_an_hei_provider_user
    and_i_have_generated_a_token

    given_i_navigate_to_the_authentication_token_index_page
    and_i_click_the_revoke_token_action
    then_i_should_see_the_revoke_token_page

    and_i_click_the_revoke_token_confirmation_button
    then_the_token_should_have_a_revoked_status
    and_i_should_no_longer_see_the_revoke_action
    and_i_should_see_when_the_token_was_revoked
  end

  scenario "when the feature flag is on I cannot revoke a token twice", feature_token_management: true do
    given_i_am_authenticated_as_an_hei_provider_user
    and_i_have_generated_a_token

    given_i_navigate_to_the_authentication_token_index_page
    and_i_click_the_revoke_token_action
    then_i_should_see_the_revoke_token_page

    and_i_click_the_revoke_token_confirmation_button
    then_the_token_should_have_a_revoked_status
    and_i_cannot_see_the_revoke_action

    and_i_navigate_to_the_revoke_token_page
    then_i_see_an_unauthorised_message
  end

private

  def and_i_have_generated_a_token
    visit authentication_tokens_path
    click_on "Generate a new token"
    fill_in "Token name", with: "My new token"
    click_on "Generate token"
    click_on "Continue to manage tokens"
  end

  def when_i_navigate_to_the_create_authentication_token_page
    visit new_authentication_token_path
  end

  def given_i_navigate_to_the_authentication_token_index_page
    visit authentication_tokens_path
  end

  def and_i_click_the_revoke_token_action
    click_on "Revoke"
  end

  def and_i_click_the_revoke_token_confirmation_button
    click_on "Yes I’m sure — revoke this token"
  end

  def then_i_should_see_the_revoke_token_page
    expect(page).to have_content("Are you sure you want to revoke this token?")
  end

  def then_the_token_should_have_a_revoked_status
    expect(page).to have_content("Revoked")
  end

  def and_i_should_no_longer_see_the_revoke_action
    expect(page).not_to have_link("Revoke")
  end

  def and_i_should_see_when_the_token_was_revoked
    expect(page).to have_content("Revoked by")
    expect(page).to have_content("on #{Time.zone.today.to_fs(:govuk)}")
  end

  def then_i_see_an_unauthorised_message
    expect(page).to have_content("You do not have permission to perform this action")
  end

  def and_i_cannot_see_the_revoke_action
    expect(page).not_to have_link("Revoke")
  end

  def and_i_navigate_to_the_revoke_token_page
    token = AuthenticationToken.last

    visit authentication_token_revoke_path(token)
  end

  def then_i_see_an_unauthorised_message
    expect(page).to have_content("You do not have permission to perform this action")
  end
end

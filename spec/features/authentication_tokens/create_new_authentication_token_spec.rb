# frozen_string_literal: true

require "rails_helper"

feature "create a new authentication token" do
  background do
    given_i_am_authenticated
    and_the_authentication_tokens_feature_flag_is_enabled
  end

  scenario "create a token" do
    # TODO: Navigate from the authentication tokens index page to the new page
    visit new_authentication_token_path
  end

private

  def and_the_authentication_tokens_feature_flag_is_enabled
  end
end

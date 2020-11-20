# frozen_string_literal: true

module Features
  module AuthenticationSteps
    attr_reader :current_user

    def given_i_am_authenticated(user: nil)
      @current_user = user || create(:user)
      set_authenticated_user

      sign_in_page = PageObjects::SignIn.new
      sign_in_page.load
      sign_in_page.sign_in_button.click
    end
  end
end

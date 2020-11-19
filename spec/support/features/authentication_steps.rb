# frozen_string_literal: true

module Features
  module AuthenticationSteps
    attr_reader :current_user

    def given_i_am_authenticated
      @current_user = create(:user, email: PERSONA_EMAILS.first)
      personas_page = PageObjects::Personas::Index.new
      personas_page.load
      personas_page.sign_in_button.click
    end
  end
end

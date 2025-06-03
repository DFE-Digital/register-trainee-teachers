# frozen_string_literal: true

module Features
  module AuthenticationSteps
    attr_reader :current_user

    def given_i_am_authenticated(user: nil)
      @current_user = UserWithOrganisationContext.new(user: user || create(:user), session: {})
      user_exists_in_dfe_sign_in(user: @current_user)

      visit_sign_in_page
    end

    def given_i_am_authenticated_as_an_hei_provider_user
      given_i_am_authenticated(user: create(:user, :hei))
    end

    def given_i_am_authenticated_as_a_lead_partner_user(user: create(:user, :with_lead_partner_organisation))
      given_i_am_authenticated(user:)
    end

    def given_i_am_authenticated_as_system_admin
      given_i_am_authenticated(user: create(:user, :system_admin))
    end

    def visit_sign_in_page
      sign_in_page = PageObjects::SignIn.new
      sign_in_page.load
      sign_in_page.sign_in_button.click
    end
  end
end

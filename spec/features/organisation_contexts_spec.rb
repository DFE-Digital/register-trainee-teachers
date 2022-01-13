# frozen_string_literal: true

require "rails_helper"

feature "setting a provider organisation context" do
  context "a user with multiple organistions" do
    background { given_i_am_authenticated(user: user) }

    before do
      given_i_visit_the_organisations_page
      then_i_should_see_a_list_of_my_providers
      then_i_should_see_a_list_of_my_lead_schools
    end

    scenario "setting a provider context" do
      when_i_click_on_a_provider_link
      then_i_should_be_redirected_to_the_start_page
    end
  end

private

  attr_reader :provider

  def given_i_visit_the_organisations_page
    organisations_index_page.load
  end

  def then_i_should_see_a_list_of_my_providers
    expect(organisations_index_page.provider_links.map(&:text)).to match_array(user.providers.map(&:name))
  end

  def then_i_should_see_a_list_of_my_lead_schools
    expect(organisations_index_page.lead_school_links.map(&:text)).to match_array(user.lead_schools.map(&:name))
  end

  def when_i_click_on_a_provider_link
    @provider = multi_organisation_user.providers.first
    organisations_index_page.provider_links.find { |link| link.text == provider.name }.click
  end

  def then_i_should_be_redirected_to_the_start_page
    expect(start_page).to be_displayed
  end

  def user
    @_user ||= create(:user, :with_multiple_organisations)
  end
end

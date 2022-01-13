# frozen_string_literal: true

require "rails_helper"

feature "setting organisation context" do
  context "a user with multiple organistions" do
    background { given_i_am_authenticated(user: user) }

    scenario "navigating to the index and setting a context" do # TODO: this should happen automatically for multi org users
      given_i_visit_the_organisations_context_page
      then_i_should_see_a_list_of_my_providers
      then_i_should_see_a_list_of_my_lead_schools
    end
  end

private

  def given_i_visit_the_organisations_context_page
    organisations_index_page.load
  end

  def then_i_should_see_a_list_of_my_providers
    expect(organisations_index_page.provider_links.map(&:text)).to match_array(user.providers.map(&:name))
  end

  def then_i_should_see_a_list_of_my_lead_schools
    expect(organisations_index_page.lead_school_links.map(&:text)).to match_array(user.lead_schools.map(&:name))
  end

  def user
    @_user ||= create(:user, :with_multiple_organisations)
  end
end

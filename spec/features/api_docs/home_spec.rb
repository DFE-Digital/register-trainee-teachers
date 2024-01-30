# frozen_string_literal: true

require "rails_helper"

feature "Home page for Register API documentation" do
  scenario "navigate to the documentation when feature flag is deactivated", feature_register_api: false do
    when_i_visit_the_documentation_page
    then_i_should_see_the_default_not_found_page
  end

  scenario "navigate to the documentation when feature flag is active", feature_register_api: true do
    when_i_visit_the_documentation_page
    then_i_should_see_the_api_docs_home_page
  end

  def when_i_visit_the_documentation_page
    visit "/api-docs"
  end

  def then_i_should_see_the_api_docs_home_page
    expect(page).to have_content("Register API documentation")
  end

  def then_i_should_see_the_default_not_found_page
    expect(page).not_to have_content("Register API documentation")
    expect(page).to have_content("Page not found")
  end
end

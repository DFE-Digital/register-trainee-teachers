# frozen_string_literal: true

require "rails_helper"

feature "Home page for Register API documentation" do
  scenario "navigate to the documentation when feature flag is deactivated", feature_register_api: false do
    when_i_visit_the_documentation_page
    then_i_should_see_the_default_not_found_page
  end

  scenario "navigate to the documentation when feature flag is active" do
    when_i_visit_the_documentation_page
    then_i_should_see_the_api_docs_home_page

    when_i_navigate_to_the_release_notes
    then_i_should_see_the_release_notes_for_the_current_and_earlier_versions

    when_i_navigate_back
    then_i_should_see_the_register_home_page
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

  def when_i_navigate_to_the_release_notes
    click_on "Release notes"
  end

  def then_i_should_see_the_release_notes_for_the_current_and_earlier_versions
    expect(page).to have_content("Register API release notes")
  end

  def when_i_navigate_back
    click_on "Back"
  end

  def then_i_should_see_the_register_home_page
    expect(page).to have_current_path(root_path)
  end
end

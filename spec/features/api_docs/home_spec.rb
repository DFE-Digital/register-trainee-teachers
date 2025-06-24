# frozen_string_literal: true

require "rails_helper"

feature "Home page for Register API documentation" do
  scenario "navigate to the documentation" do
    when_i_visit_the_documentation_page
    then_i_should_see_the_api_docs_home_page

    when_i_navigate_to_the_release_notes
    then_i_should_see_the_release_notes_for_the_current_and_earlier_versions

    when_i_click_on_the_logo
    then_i_should_see_the_register_home_page
  end

  def when_i_visit_the_documentation_page
    visit "/api-docs/"
  end

  def then_i_should_see_the_api_docs_home_page
    expect(page).to have_content("Register API documentation")
  end

  def when_i_navigate_to_the_release_notes
    click_on "Release notes"
  end

  def then_i_should_see_the_release_notes_for_the_current_and_earlier_versions
    expect(page).to have_content("Release notes")
  end

  def when_i_click_on_the_logo
    find(".govuk-header__link--homepage", text: "Register trainee teachers").click
  end

  def then_i_should_see_the_register_home_page
    expect(page).to have_current_path(root_path)
  end
end
# frozen_string_literal: true

require "rails_helper"

feature "References documentation page for Register API" do
  scenario "navigate to the documentation when feature flag is active" do
    when_i_visit_the_documentation_page
    and_i_navigate_to_the_api_reference
    then_i_should_see_the_api_reference_for_the_current_version
    and_i_should_see_links_to_other_versions

    when_i_click_on_a_link_to_another_version
    then_i_should_see_the_api_reference_for_the_other_version
  end

  def when_i_visit_the_documentation_page
    visit "/api-docs"
  end

  def and_i_navigate_to_the_api_reference
    click_on("API reference", class: "moj-primary-navigation__link")
  end

  def then_i_should_see_the_api_reference_for_the_current_version
    expect(page).to have_content("Register API reference")
  end

  def and_i_should_see_links_to_other_versions
    Settings.api.allowed_versions.each do |version|
      expect(page).to have_link(version, href: api_docs_versioned_reference_path(api_version: version))
    end
  end

  def when_i_click_on_a_link_to_another_version
    click_on "v2025.0-rc"
  end

  def then_i_should_see_the_api_reference_for_the_other_version
    expect(page).to have_content("Register API reference")
    expect(page).to have_current_path(api_docs_versioned_reference_path(api_version: "v2025.0-rc"))
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "References documentation page for Register API" do
  scenario "navigate to the documentation when feature flag is active" do
    when_i_visit_the_documentation_page
    then_i_should_see_the_api_reference_for_the_current_version
    and_i_should_see_links_to_other_versions

    when_i_click_on_a_link_to_another_version
    then_i_should_see_the_api_reference_for_the_other_version
  end

  def when_i_visit_the_documentation_page
    visit "/api-docs/"
  end

  def then_i_should_see_the_api_reference_for_the_current_version
    expect(page).to have_content("Register API documentation")
  end

  def and_i_should_see_links_to_other_versions
    Settings.api.allowed_versions.each do |version|
      expect(page).to have_link(version, href: "./#{version}/index.html")
    end
  end

  def when_i_click_on_a_link_to_another_version
    click_on "v2025.0"
  end

  def then_i_should_see_the_api_reference_for_the_other_version
    expect(page).to have_css("h1", text: "v2025.0")
  end
end

# frozen_string_literal: true

require "rails_helper_axe"

RSpec.feature "view components", axe: true,
                                 driver: :selenium_headless do
  before :each do
    # NOTE: some of the components
    Capybara.raise_server_errors = false
  end

  all_links = (ViewComponent::Preview.all.map do |component|
    component.examples.map do |example|
      "#{Rails.application.config.view_component.preview_route}/#{component.preview_name}/#{example}"
    end
  end).flatten

  exempt_links = [
    "/view_components/header/view/with_a_user_signed_in",
    "/view_components/header/view/with_custom_service_name",
    "/view_components/header/view/with_our_service_name",
  ]

  links_to_be_tested = all_links - exempt_links

  it "has no drift" do
    expect(all_links.count).to eq(links_to_be_tested.count + exempt_links.count)
  end

  shared_examples "navigate to" do |link, skip|
    scenario "navigate to #{link}", skip: skip do
      visit link

      expect(page).to be_axe_clean.within("#main-content")
    end
  end

  links_to_be_tested.each do |link|
    include_examples "navigate to", link, false
  end

  exempt_links.each do |link|
    include_examples "navigate to", link, "it has been exempted"
  end
end

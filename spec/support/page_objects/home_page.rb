require_relative "sections/home_hero"

module PageObjects
  class HomePage < PageObjects::BasePage
    set_url "/pages/home"

    section :hero, PageObjects::Sections::HomeHero, ".hero"
  end
end

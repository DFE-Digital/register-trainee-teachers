# frozen_string_literal: true

require "rails_helper"

feature "View the timeline", js: true do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(:submitted_for_trn)
  end

  scenario "viewing the timeline of trainee" do
    when_i_view_the_trainee_page
    and_i_click_on_trainee_name
    and_i_click_on_the_timeline_tab
    then_i_should_see_the_trainee_timeline
  end

  def when_i_view_the_trainee_page
    trainee_index_page.load
  end

  def and_i_click_on_trainee_name
    trainee_index_page.trainee_name.first.click
  end

  def and_i_click_on_the_timeline_tab
    record_page.timeline_tab.click
  end

  def then_i_should_see_the_trainee_timeline
    expect(timeline_page).to be_displayed(id: trainee.slug)

    expect(timeline_page.tab_title.text).to eq("Timeline")
    within("div.app-timeline") do
      expect(page).to have_content("Record created")
    end
  end
end

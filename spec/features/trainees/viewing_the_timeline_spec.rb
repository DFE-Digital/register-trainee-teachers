# frozen_string_literal: true

require "rails_helper"

feature "View the timeline" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists(state: :submitted_for_trn)
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
    expect(timeline_page).to be_displayed(id: trainee.id)
  end

  def record_page
    @record_page ||= PageObjects::Trainees::Record.new
  end

  def timeline_page
    @timeline_page ||= PageObjects::Trainees::Timeline.new
  end
end

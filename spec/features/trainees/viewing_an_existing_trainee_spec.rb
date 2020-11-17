# frozen_string_literal: true

require "rails_helper"

feature "View trainees" do
  background { given_i_am_authenticated }

  scenario "viewing the personal details of trainee" do
    given_a_trainee_exists
    when_i_view_the_trainee_index_page
    and_i_click_on_trainee_name
    then_i_should_see_the_trainee_details
  end

  def when_i_view_the_trainee_index_page
    trainee_index_page.load
  end

  def and_i_click_on_trainee_name
    trainee_index_page.trainee_name.first.click
  end

  def then_i_should_see_the_trainee_details
    @show_page ||= PageObjects::Trainees::Show.new
    expect(@show_page).to be_displayed(id: trainee.id)
  end
end

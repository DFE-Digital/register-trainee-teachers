# frozen_string_literal: true

require "rails_helper"

feature "View trainees" do
  background { given_i_am_authenticated }

  scenario "viewing the personal details of trainee" do
    given_a_trainee_exists
    when_i_view_the_trainee_index_page
    then_i_see_the_draft_trainee_data
    and_i_click_on_trainee_name
    then_i_should_see_the_trainee_details
  end

  def when_i_view_the_trainee_index_page
    trainee_index_page.load
  end

  def then_i_see_the_draft_trainee_data
    expect(trainee_index_page).to have_draft_trainee_data
  end

  def and_i_click_on_trainee_name
    trainee_index_page.trainee_name.first.click
  end

  def then_i_should_see_the_trainee_details
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end
end

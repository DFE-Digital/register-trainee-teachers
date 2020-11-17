# frozen_string_literal: true

require "rails_helper"

feature "Create trainee journey" do
  background { given_i_am_authenticated }

  scenario "setting up an initial assessment only record" do
    when_i_am_viewing_the_list_of_trainees
    and_i_click_on_add_trainee_button
    and_i_select_assessment_only_route
    and_i_fill_in_train_id
    and_i_save_the_form
    then_i_should_see_the_new_trainee_overview
  end

private

  def when_i_am_viewing_the_list_of_trainees
    trainee_index_page.load
  end

  def and_i_click_on_add_trainee_button
    @new_page ||= PageObjects::Trainees::New.new
    trainee_index_page.add_trainee_link.click
  end

  def and_i_select_assessment_only_route
    @new_page.assessment_only.click
  end

  def and_i_fill_in_train_id
    @new_page.trainee_id_input.set("123")
  end

  def and_i_save_the_form
    @show_page ||= PageObjects::Trainees::Show.new
    @not_supported_route_page ||= PageObjects::Trainees::NotSupportedRoute.new
    @new_page.continue_button.click
  end

  def then_i_should_see_the_new_trainee_overview
    expect(@show_page).to be_displayed
  end
end

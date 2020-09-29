require "rails_helper"

RSpec.feature "Create trainee journey" do
  scenario "see summary page afterwards" do
    when_i_am_viewing_the_list_of_trainees
    and_i_click_on_add_data_button
    and_i_fill_in_train_id
    and_i_fill_in_first_and_last_name
    and_i_save_the_form
    then_i_should_see_the_new_trainee_details
  end

private

  def when_i_am_viewing_the_list_of_trainees
    @index_page ||= PageObjects::Trainees::Index.new
    @index_page.load
  end

  def and_i_click_on_add_data_button
    @new_page ||= PageObjects::Trainees::New.new
    @index_page.add_data_link.click
  end

  def and_i_fill_in_train_id
    @new_page.trainee_id_input.set("123")
  end

  def and_i_fill_in_first_and_last_name
    @new_page.trainee_first_names_input.set("Tim")
    @new_page.trainee_last_name_input.set("Smith")
  end

  def and_i_save_the_form
    @show_page ||= PageObjects::Trainees::Show.new
    @new_page.continue_button.click
  end

  def then_i_should_see_the_new_trainee_details
    expect(@show_page).to be_displayed
    # expect(@show_page).to have_content("Trainee ID 123")
  end
end

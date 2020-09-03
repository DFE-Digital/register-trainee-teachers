require "rails_helper"

feature "edit training details" do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_training_details_page
    and_i_enter_valid_parameters
    then_i_am_redirected_to_the_summary_page
  end

  def given_a_trainee_exists
    @trainee = create(:trainee)
  end

  def when_i_visit_the_training_details_page
    visit "/trainees/#{@trainee.id}/training-details"
  end

  def and_i_enter_valid_parameters
    page_object = PageObjects::Trainees::TrainingDetails.new
    set_date_fields(page_object, "start_date", "10/01/2021")
    page_object.full_time.click
    page_object.teaching_scholars_yes.click
    page_object.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    expect(page.current_path).to eq("/trainees/#{@trainee.id}")
  end

  def set_date_fields(page_object, field_prefix, date_string)
    day, month, year = date_string.split("/")
    page_object.send("#{field_prefix}_day").set day
    page_object.send("#{field_prefix}_month").set month
    page_object.send("#{field_prefix}_year").set year
  end
end

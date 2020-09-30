require "rails_helper"

feature "edit personal details", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_enter_valid_parameters
    then_i_am_redirected_to_the_summary_page
    and_the_personal_details_are_updated
  end

  def given_a_trainee_exists
    @trainee = create(:trainee)
  end

  def and_nationalities_exist_in_the_system
    @nationality = create(:nationality, name: "british")
  end

  def when_i_visit_the_personal_details_page
    @personal_details_page ||= PageObjects::Trainees::PersonalDetails.new
    @personal_details_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @personal_details_page.first_names.set("Tim")
    @personal_details_page.last_name.set("Smith")
    set_date_fields("dob", "01/01/1986")
    @personal_details_page.gender.choose("Male")
    @personal_details_page.nationality.check(@nationality.name.titleize)
    @personal_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_personal_details_are_updated
    when_i_visit_the_personal_details_page
    expect(@personal_details_page.first_names.value).to eq("Tim")
  end

  def set_date_fields(field_prefix, date_string)
    day, month, year = date_string.split("/")
    @personal_details_page.send("#{field_prefix}_day").set(day)
    @personal_details_page.send("#{field_prefix}_month").set(month)
    @personal_details_page.send("#{field_prefix}_year").set(year)
  end
end

require "rails_helper"

feature "edit personal details", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_summary_page
    and_the_personal_details_are_updated
  end

  scenario "edit with invalid parameters" do
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_submit_the_form
    then_i_see_error_messages
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
    @personal_details_page.set_date_fields("dob", "01/01/1986")
    @personal_details_page.gender.choose("Male")
    @personal_details_page.nationality.check(@nationality.name.titleize)
  end

  def and_confirm_my_details
    @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.id, section: "personal-details")
    @confirm_page.submit_button.click
  end

  def and_i_submit_the_form
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

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t(
        "activemodel.errors.models.personal_detail.attributes.nationality_ids.empty_nationalities",
      ),
    )
  end
end

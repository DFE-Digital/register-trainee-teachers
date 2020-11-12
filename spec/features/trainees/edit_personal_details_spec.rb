require "rails_helper"

feature "edit personal details", type: :feature do
  background { given_i_am_authenticated }

  scenario "updates personal details with valid data" do
    given_valid_personal_details_are_provided
    then_the_personal_details_are_updated
  end

  scenario "renders a completed status when valid personal details provided" do
    given_valid_personal_details_are_provided
    then_the_personal_details_section_should_be_completed
  end

  scenario "renders an 'in progress' status when valid personal details partially provided" do
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    and_confirm_my_details(checked: false)
    then_i_am_redirected_to_the_summary_page
    then_the_personal_details_section_should_be_in_progress
  end

  scenario "redirects to confirm page when section is completed" do
    given_valid_personal_details_are_provided
    when_i_visit_the_personal_details_page
    then_i_am_redirected_to_the_confirm_page
  end

  scenario "does not update the personal details with invalid data" do
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_submit_the_form
    then_i_see_error_messages
  end

private

  def given_valid_personal_details_are_provided
    given_a_trainee_exists
    and_nationalities_exist_in_the_system
    when_i_visit_the_personal_details_page
    and_i_enter_valid_parameters
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_summary_page
  end

  def given_a_trainee_exists
    @trainee ||= create(:trainee, provider: current_user.provider)
  end

  def and_nationalities_exist_in_the_system
    @nationality ||= create(:nationality, name: "british")
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

  def and_confirm_my_details(checked: true)
    checked_option = checked ? "check" : "uncheck"
    @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.id, section: "personal-details")
    @confirm_page.confirm.public_send(checked_option)
    @confirm_page.submit_button.click
  end

  def then_i_am_redirected_to_the_confirm_page
    @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.id, section: "personal-details")
  end

  def and_i_submit_the_form
    @personal_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_return_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    @summary_page.load
  end

  def then_the_personal_details_are_updated
    @trainee.reload
    expect(@trainee.progress.personal_details).to be_truthy
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t(
        "activemodel.errors.models.personal_detail.attributes.nationality_ids.empty_nationalities",
      ),
    )
  end

  def then_the_personal_details_section_should_be_completed
    expect(@summary_page.personal_details.status.text).to eq(Progress::STATUSES[:completed])
  end

  def then_the_personal_details_section_should_be_in_progress
    expect(@summary_page.personal_details.status.text).to eq(Progress::STATUSES[:in_progress])
  end
end

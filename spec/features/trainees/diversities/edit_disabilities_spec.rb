require "rails_helper"

feature "edit disability details", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    and_disabilities_exist_in_the_system
    when_i_visit_the_disability_details_page
  end

  scenario "choosing a disability" do
    and_i_choose_a_disability
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_summary_page
    and_the_disability_details_are_updated
  end

  scenario "submitting with no disability chosen" do
    and_i_submit_the_form
    then_i_see_error_messages
  end

  def and_disabilities_exist_in_the_system
    @disability = create(:disability, name: "deaf")
  end

  def when_i_visit_the_disability_details_page
    @disabilities_page ||= PageObjects::Trainees::Diversities::Disabilities.new
    @disabilities_page.load(id: trainee.id)
  end

  def and_i_choose_a_disability
    @disabilities_page.disability.check(@disability.name)
  end

  def and_i_submit_the_form
    @disabilities_page.submit_button.click
  end

  def and_confirm_my_details
    @confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: trainee.id, section: "disabilities")
    @confirm_page.submit_button.click
  end

  def and_the_disability_details_are_updated
    expect(trainee.reload.disabilities).to include(@disability)
  end

  def then_i_see_error_messages
    expect(page).to have_content(
      I18n.t(
        "activemodel.errors.models.diversities/disability_detail.attributes.disability_ids.empty_disabilities",
      ),
    )
  end
end

require "rails_helper"

feature "edit contact details", type: :feature do
  scenario "edit with valid parameters" do
    given_a_trainee_exists
    when_i_visit_the_contact_details_page
    and_i_enter_valid_parameters
    then_i_am_redirected_to_the_summary_page
    and_the_contact_details_are_updated
  end

  def given_a_trainee_exists
    @trainee = create(:trainee)
  end

  def when_i_visit_the_contact_details_page
    @contact_details_page ||= PageObjects::Trainees::ContactDetails.new
    @contact_details_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @new_address_line = Faker::Address.street_name

    @contact_details_page.address_line_one.set(@new_address_line)
    @contact_details_page.submit_button.click
  end

  def then_i_am_redirected_to_the_summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
    expect(@summary_page).to be_displayed(id: @trainee.id)
  end

  def and_the_contact_details_are_updated
    when_i_visit_the_contact_details_page
    expect(@contact_details_page.address_line_one.value).to eq(@new_address_line)
  end
end

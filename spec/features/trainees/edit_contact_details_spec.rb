require "rails_helper"

feature "edit contact details", type: :feature do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
    when_i_visit_the_contact_details_page
  end

  scenario "edit with valid parameters" do
    and_i_enter_valid_parameters
    and_i_submit_the_form
    and_confirm_my_details
    then_i_am_redirected_to_the_summary_page
    and_the_contact_details_are_updated
  end

  scenario "changing locale clears previous address" do
    and_i_enter_an_international_address
    and_confirm_my_details
    then_i_am_redirected_to_the_summary_page
    and_the_old_address_is_cleared
  end

  def when_i_visit_the_contact_details_page
    @contact_details_page ||= PageObjects::Trainees::ContactDetails.new
    @contact_details_page.load(id: @trainee.id)
  end

  def and_i_enter_valid_parameters
    @new_address_line = Faker::Address.street_name

    @contact_details_page.address_line_one.set(@new_address_line)
  end

  def and_i_submit_the_form
    @contact_details_page.submit_button.click
  end

  def and_confirm_my_details
    @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    expect(@confirm_page).to be_displayed(id: @trainee.id, section: "contact-details")
    @confirm_page.submit_button.click
  end

  def and_i_enter_an_international_address
    @new_address_line = Faker::Address.street_name

    @contact_details_page.non_uk_locale.choose
    @contact_details_page.international_address.set(@new_address_line)
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

  def and_the_old_address_is_cleared
    when_i_visit_the_contact_details_page
    expect(@contact_details_page.international_address.value).to eq(@new_address_line)
    expect(@contact_details_page.address_line_one.value).to be_nil
    expect(@contact_details_page.address_line_two.value).to be_nil
    expect(@contact_details_page.town_city.value).to be_nil
    expect(@contact_details_page.postcode.value).to be_nil
  end
end

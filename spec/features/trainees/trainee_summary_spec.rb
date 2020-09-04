require "rails_helper"

feature "Trainee summary page", type: :system do
  scenario "displays the personal details" do
    given_a_trainee_exists
    when_i_visit_the_summary_page
    then_i_can_see_the_personal_details
  end

  scenario "displays the contact details" do
    given_a_trainee_exists
    when_i_visit_the_summary_page
    then_i_can_see_the_contact_details
  end

  def given_a_trainee_exists
    @trainee = create(:trainee)
  end

  def when_i_visit_the_summary_page
    @summary_page ||= PageObjects::Trainees::SummaryPage.new
    @summary_page.load(id: @trainee.id)
  end

  def then_i_can_see_the_personal_details
    expect(@summary_page.personal_details.trainee_id.text).to eq(@trainee.trainee_id)
  end

  def then_i_can_see_the_contact_details
    expected_address = "#{@trainee.address_line_one}, #{@trainee.address_line_two}, #{@trainee.town_city}, #{@trainee.county}"

    expect(@summary_page.contact_details.address.text).to eq(expected_address)
    expect(@summary_page.contact_details.postcode.text).to eq(@trainee.postcode)
    expect(@summary_page.contact_details.phone.text).to eq(@trainee.phone)
    expect(@summary_page.contact_details.email.text).to eq(@trainee.email)
  end
end

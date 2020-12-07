# frozen_string_literal: true

require "rails_helper"

feature "Trainee summary page", type: :system do
  xscenario "displays the personal details" do
    given_a_trainee_exists
    when_i_visit_the_summary_page
    then_i_can_see_the_personal_details
  end

  xscenario "displays the contact details" do
    given_a_trainee_exists
    when_i_visit_the_summary_page
    then_i_can_see_the_contact_details
  end

  xscenario "displays the training details" do
    given_a_trainee_exists
    when_i_visit_the_summary_page
    then_i_can_see_the_training_details
  end

  def then_i_can_see_the_personal_details
    expect(summary_page.personal_details.trainee_id.text).to eq(trainee.trainee_id)
  end

  def then_i_can_see_the_training_details
    expect(summary_page.training_details.start_date.text).to eq(trainee.start_date.to_s)
    expect(summary_page.training_details.full_time_part_time.text).to eq(trainee.full_time_part_time.to_s)
    expect(summary_page.training_details.teaching_scholars.text).to eq(trainee.teaching_scholars.to_s)
  end

  def then_i_can_see_the_contact_details
    expected_address = "#{trainee.address_line_one}, #{trainee.address_line_two}, #{trainee.town_city}"

    expect(summary_page.contact_details.address.text).to eq(expected_address)
    expect(summary_page.contact_details.postcode.text).to eq(trainee.postcode)
    expect(summary_page.contact_details.email.text).to eq(trainee.email)
  end
end

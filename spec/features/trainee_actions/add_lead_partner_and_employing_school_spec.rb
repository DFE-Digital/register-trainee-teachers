# frozen_string_literal: true

require "rails_helper"

feature "add lead partner and employing school" do
  include TraineeHelper

  background do
    given_i_am_authenticated
  end

  scenario "add a lead partner and employing school", "feature_routes.school_direct_salaried": true do
    given_lead_partner_and_employing_school_exist_in_the_system
    given_a_trainee_exists(:school_direct_salaried)
    and_i_am_on_the_trainee_record_page
    then_i_see_the_lead_partner_and_employing_school_details
    when_i_click_on_the_lead_partner_and_employing_schools
    and_i_see_the_edit_lead_partner_details_page
    and_i_see_the_not_applicable_lead_partner_radio_option(false)
    and_i_choose_the_not_applicable_lead_partner_option(false)
    and_i_click_on_continue
    then_i_see_the_lead_partner_edit_page
    when_i_fill_in_my_lead_partner
    and_i_click_on_continue
    then_i_see_the_lead_partner_search_page
    when_i_choose_a_lead_partner
    and_i_click_on_continue
    then_i_see_the_edit_employing_school_details_page
    and_i_see_the_not_applicable_employing_school_radio_option(false)
    and_i_choose_the_not_applicable_employing_school_option(false)
    and_i_click_on_continue
    then_i_see_the_employing_school_edit_page
    when_i_fill_in_my_employing_school
    and_i_click_on_continue
    then_i_see_the_employing_school_search_page
    when_i_choose_an_employing_school
    and_i_click_on_continue
    then_i_see_the_confirm_my_details_page
    when_i_click_on_change_lead_partner
    and_i_see_the_not_applicable_lead_partner_radio_option(false)
    and_i_choose_the_not_applicable_lead_partner_option(true)
    and_i_click_on_continue
    then_i_see_the_confirm_my_details_page
    when_i_confirm_my_details
    then_the_lead_and_employing_schools_section_is_marked_completed
  end

  scenario "add a lead partner", "feature_routes.school_direct_salaried": true do
    given_lead_partner_and_employing_school_exist_in_the_system
    given_a_trainee_exists(:school_direct_salaried)
    and_i_am_on_the_trainee_record_page
    then_i_see_the_lead_partner_and_employing_school_details
    when_i_click_on_the_lead_partner_and_employing_schools
    and_i_see_the_edit_lead_partner_details_page
    and_i_see_the_not_applicable_lead_partner_radio_option(false)
    and_i_choose_the_not_applicable_lead_partner_option(false)
    and_i_click_on_continue
    then_i_see_the_lead_partner_edit_page
    when_i_fill_in_my_lead_partner
    and_i_click_on_continue
    then_i_see_the_lead_partner_search_page
    when_i_choose_a_lead_partner
    and_i_click_on_continue
    then_i_see_the_edit_employing_school_details_page
    and_i_see_the_not_applicable_employing_school_radio_option(false)
    and_i_choose_the_not_applicable_employing_school_option(true)
    and_i_click_on_continue
    when_i_try_to_visit_the_edit_employing_school_page_by_url
    then_i_see_the_edit_employing_school_details_page
    and_i_see_the_not_applicable_employing_school_radio_option(true)
    and_i_click_on_continue
    then_i_see_the_confirm_my_details_page
    when_i_confirm_my_details
    then_the_lead_and_employing_schools_section_is_marked_completed
  end

  scenario "add an employing school", "feature_routes.school_direct_salaried": true do
    given_lead_partner_and_employing_school_exist_in_the_system
    given_a_trainee_exists(:school_direct_salaried)
    and_i_am_on_the_trainee_record_page
    then_i_see_the_lead_partner_and_employing_school_details
    when_i_click_on_the_lead_partner_and_employing_schools
    and_i_see_the_edit_lead_partner_details_page
    and_i_see_the_not_applicable_lead_partner_radio_option(false)
    and_i_choose_the_not_applicable_lead_partner_option(true)
    and_i_click_on_continue
    then_i_see_the_edit_employing_school_details_page
    when_i_try_to_visit_the_lead_partner_edit_page_by_url
    then_i_see_the_edit_lead_partner_details_page
    and_i_choose_the_not_applicable_lead_partner_option(true)
    and_i_click_on_continue
    and_i_see_the_not_applicable_employing_school_radio_option(false)
    and_i_choose_the_not_applicable_employing_school_option(false)
    and_i_click_on_continue
    then_i_see_the_employing_school_edit_page
    when_i_fill_in_my_employing_school
    and_i_click_on_continue
    then_i_see_the_employing_school_search_page
    when_i_choose_an_employing_school
    and_i_click_on_continue
    then_i_see_the_confirm_my_details_page
    when_i_confirm_my_details
    then_the_lead_and_employing_schools_section_is_marked_completed
  end

  def then_i_see_the_lead_partner_and_employing_school_details
    expect(record_page).to have_school_detail
  end

  def and_i_see_the_edit_lead_partner_details_page
    expect(edit_trainee_lead_partner_details_page).to be_displayed
    expect(edit_trainee_lead_partner_details_page).to have_content(
      "Is there a lead partner?",
    )
    expect(edit_trainee_lead_partner_details_page).to have_content(
      "You do not need to provide a lead partner if the trainee is funded or employed privately.",
    )
  end

  def and_i_see_the_not_applicable_lead_partner_radio_option(value)
    expect(edit_trainee_lead_partner_details_page).to have_lead_partner_radio_button_checked(value)
  end

  def and_i_choose_the_not_applicable_lead_partner_option(value)
    edit_trainee_lead_partner_details_page.select_radio_button(value)
  end

  def and_i_click_on_continue
    edit_trainee_lead_partner_details_page.continue_button.click
  end

  def then_i_see_the_lead_partner_edit_page
    expect(edit_lead_partner_page).to be_displayed
    expect(edit_lead_partner_page).to have_content(
      "The lead partner is the main organisation and point of contact for training providers, placements and partner schools in the School Direct partnership.",
    )
    expect(edit_lead_partner_page).to have_content(
      "The lead partner you select will be able to view trainee’s record.",
    )
    expect(edit_lead_partner_page).to have_content(
      "Search for a lead partner by name, postcode, school URN or training provider UKPRN",
    )
    expect(edit_lead_partner_page).to have_content(
      "If the lead partner is missing from the list, try searching for its unique reference number (URN) on Get information about schools (opens in a new tab).",
    )
    expect(edit_employing_school_page).to have_link(text: "Get information about schools", href: "https://get-information-schools.service.gov.uk/")
    expect(edit_lead_partner_page).to have_content(
      "If you still cannot find the lead partner, contact becomingateacher@digital.education.gov.uk",
    )
    expect(edit_employing_school_page).to have_link("becomingateacher@digital.education.gov.uk")
    expect(edit_lead_partner_page).to have_content(
      "You do not need to provide a lead partner if the trainee is funded or employed privately.",
    )
  end

  def then_i_see_the_lead_partner_search_page
    expect(lead_partners_search_page).to be_displayed
  end

  def when_i_fill_in_my_lead_partner
    edit_lead_partner_page.lead_partner.fill_in with: @lead_partner.name.split.first
  end

  def when_i_click_on_the_lead_partner_and_employing_schools
    review_draft_page.lead_and_employing_schools_section.link.click
  end

  def when_i_type_the_lead_partner_name
    lead_partners_search_page.choose_lead_partner(id: @lead_partner.id)
  end

  def when_i_choose_a_lead_partner
    lead_partners_search_page.choose_lead_partner(id: @lead_partner.id)
  end

  def then_i_see_the_employing_school_search_page
    expect(employing_schools_search_page).to be_displayed
  end

  def then_i_see_the_employing_school_edit_page
    expect(edit_employing_school_page).to be_displayed
    expect(edit_employing_school_page).to have_content(
      "Search for a school by its unique reference number (URN), name or postcode",
    )
    expect(edit_employing_school_page).to have_content(
      "If the employing school is missing from the list, try searching for its unique reference number (URN) on Get information about schools (opens in a new tab).",
    )
    expect(edit_employing_school_page).to have_link(text: "Get information about schools", href: "https://get-information-schools.service.gov.uk/")
    expect(edit_employing_school_page).to have_content(
      "If you still cannot find the school, contact becomingateacher@digital.education.gov.uk",
    )
    expect(edit_employing_school_page).to have_link("becomingateacher@digital.education.gov.uk")
    expect(edit_employing_school_page).to have_content(
      "You do not need to provide an employing school if the trainee is funded or employed privately.",
    )
  end

  def when_i_fill_in_my_employing_school
    edit_employing_school_page.employing_school_no_js.fill_in with: @employing_school.name.split.first
  end

  def when_i_choose_an_employing_school
    employing_schools_search_page.choose_school(id: @employing_school.id)
  end

  def then_i_see_the_edit_employing_school_details_page
    expect(edit_trainee_employing_school_details_page).to be_displayed
    expect(edit_trainee_employing_school_details_page).to have_content(
      "Is there an employing school?",
    )
    expect(edit_trainee_employing_school_details_page).to have_content(
      "You do not need to provide an employing school if the trainee is funded or employed privately.",
    )
  end

  def and_i_see_the_not_applicable_employing_school_radio_option(value)
    expect(edit_trainee_employing_school_details_page).to have_employing_school_radio_button_checked(value)
  end

  def and_i_choose_the_not_applicable_employing_school_option(value)
    edit_trainee_employing_school_details_page.select_radio_button(value)
  end

  def then_i_see_the_confirm_my_details_page
    expect(confirm_details_page).to be_displayed
  end

  def when_i_confirm_my_details
    confirm_details_page.confirm.check
    confirm_details_page.continue_button.click
  end

  def then_the_lead_and_employing_schools_section_is_marked_completed
    expect(review_draft_page).to have_lead_and_employing_school_information_completed
  end

  def when_i_click_on_change_lead_partner
    confirm_details_page.change.click
  end

  def when_i_try_to_visit_the_edit_employing_school_page_by_url
    employing_schools_search_page.load(trainee_id: trainee.slug)
  end

  def when_i_try_to_visit_the_lead_partner_edit_page_by_url
    edit_lead_partner_page.load(trainee_id: trainee.slug)
  end

  alias_method :then_i_see_the_edit_lead_partner_details_page, :and_i_see_the_edit_lead_partner_details_page
end

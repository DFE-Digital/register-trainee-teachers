# frozen_string_literal: true

require "rails_helper"

feature "edit schools spec" do
  context "as a school direct salaried trn_submitted trainee" do
    before do
      given_i_am_authenticated
      given_a_school_direct_salaried_trainee_submitted_for_trn_exists
      and_a_number_of_lead_partners_exist
      and_a_number_of_employing_schools_exist
      and_i_visit_the_trainee_record_page
    end

    scenario "changing the lead partner", js: true do
      when_i_see_the_lead_partner
      and_i_click_on_change_lead_partner(:lead_partner)
      and_i_see_the_edit_lead_partner_details_page
      and_i_continue
      and_i_am_on_the_edit_lead_partner_page
      and_i_fill_in_my_lead_partner
      and_i_click_the_first_item_in_the_list_lead_partner
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
      and_i_see_the_updated_lead_partner
    end

    scenario "choosing not applicable for lead partner" do
      when_i_see_the_lead_partner
      and_i_click_on_change_lead_partner(:lead_partner)
      and_i_see_the_edit_lead_partner_details_page
      and_i_see_the_not_applicable_lead_partner_radio_option(false)
      and_i_choose_the_not_applicable_lead_partner_option(true)
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
      and_the_lead_partner_displays_not_applicable
    end

    scenario "changing the employing school", js: true do
      when_i_see_the_employing_school
      and_i_click_on_change_school(:employing_school)
      and_i_see_the_edit_employing_school_details_page
      and_i_continue
      and_i_am_on_the_edit_employing_school_page
      and_i_fill_in_my_employing_school
      and_i_click_the_first_item_in_the_list_employing_school
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
      and_i_see_the_updated_employing_school
    end

    scenario "choosing not applicable for employing school" do
      when_i_see_the_employing_school
      and_i_click_on_change_school(:employing_school)
      and_i_see_the_edit_employing_school_details_page
      and_i_see_the_not_applicable_employing_school_radio_option(false)
      and_i_choose_the_not_applicable_employing_school_option(true)
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
      and_the_employing_school_displays_not_applicable
    end
  end

  context "as a school direct tuition fee trn_submitted trainee" do
    before do
      given_i_am_authenticated
      given_a_school_direct_tuition_fee_trainee_submitted_for_trn_exists
      and_a_number_of_lead_partners_exist
      and_a_number_of_employing_schools_exist
      and_i_visit_the_trainee_record_page
    end

    scenario "changing the lead partner", js: true do
      when_i_see_the_lead_partner
      and_i_click_on_change_lead_partner(:lead_partner)
      and_i_see_the_edit_lead_partner_details_page
      and_i_continue
      and_i_am_on_the_edit_lead_partner_page
      and_i_fill_in_my_lead_partner
      and_i_click_the_first_item_in_the_list_lead_partner
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
      and_i_see_the_updated_lead_partner
    end
  end

private

  def given_a_school_direct_salaried_trainee_submitted_for_trn_exists
    given_a_trainee_exists(
      :completed,
      :school_direct_salaried,
      :with_lead_partner,
      :with_employing_school,
      :submitted_for_trn,
    )
  end

  def given_a_school_direct_tuition_fee_trainee_submitted_for_trn_exists
    given_a_trainee_exists(:completed, :school_direct_tuition_fee, :with_lead_partner, :submitted_for_trn)
  end

  def when_i_see_the_lead_partner
    within(record_page.record_detail) do
      expect(record_page).to have_content(trainee.lead_partner.name)
    end
  end

  def when_i_see_the_employing_school
    within(record_page.record_detail) do
      expect(record_page).to have_content(trainee.employing_school.name)
    end
  end

  def and_i_see_the_not_applicable_lead_partner_radio_option(value)
    expect(edit_trainee_lead_partner_details_page).to have_lead_partner_radio_button_checked(value)
  end

  def and_i_choose_the_not_applicable_lead_partner_option(value)
    edit_trainee_lead_partner_details_page.select_radio_button(value)
  end

  def and_i_fill_in_my_lead_partner
    edit_lead_partner_page.lead_partner.fill_in with: my_lead_partner_name
  end

  def and_i_fill_in_my_employing_school
    edit_employing_school_page.employing_school.fill_in with: my_employing_school_name
  end

  def and_i_am_on_the_edit_lead_partner_page
    expect(edit_lead_partner_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_i_am_on_the_edit_employing_school_page
    expect(edit_employing_school_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_i_click_the_first_item_in_the_list_lead_partner
    click(edit_lead_partner_page.autocomplete_list_item)
  end

  def and_i_click_the_first_item_in_the_list_employing_school
    click(edit_employing_school_page.autocomplete_list_item)
  end

  def and_i_continue
    click(edit_lead_partner_page.submit)
  end

  def and_a_number_of_lead_partners_exist
    @lead_partners = create_list(:lead_partner, 1, :school)
  end

  def and_a_number_of_employing_schools_exist
    @employing_schools = create_list(:school, 1)
  end

  def and_i_visit_the_trainee_record_page
    record_page.load(id: trainee.slug)
  end

  def my_lead_partner_name
    my_lead_partner.name.split.first
  end

  def my_employing_school_name
    my_employing_school.name.split.first
  end

  def my_lead_partner
    @my_lead_partner ||= @lead_partners.sample
  end

  def my_employing_school
    @my_employing_school ||= @employing_schools.sample
  end

  def then_i_am_redirected_to_the_confirm_lead_partner_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_lead_partners_page_filtered_by_my_query
    expect(training_partners_search_page).to be_displayed(trainee_id: trainee.slug, query: my_lead_partner_name)
  end

  def and_i_click_on_change_school(school)
    record_page.public_send("change_#{school}").click
  end

  def and_i_click_on_change_lead_partner(lead_partner)
    record_page.public_send("change_#{lead_partner}").click
  end

  def then_i_am_redirected_to_the_confirm_schools_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def and_i_check_employing_school_is_not_applicable
    edit_employing_school_page.not_applicable_checkbox.check
  end

  def and_the_employing_school_displays_not_applicable
    expect(confirm_schools_page.employing_school_row).to have_text(I18n.t(:not_applicable))
  end

  def and_the_lead_partner_displays_not_applicable
    expect(confirm_schools_page.lead_partner_row).to have_text(I18n.t(:not_applicable))
  end

  def and_i_see_the_edit_lead_partner_details_page
    expect(edit_trainee_lead_partner_details_page).to be_displayed
    expect(edit_trainee_lead_partner_details_page).to have_content(
      "Is there a training partner?",
    )
    expect(edit_trainee_lead_partner_details_page).to have_content(
      "You do not need to provide a training partner if the trainee is funded or employed privately.",
    )
  end

  def and_i_see_the_edit_employing_school_details_page
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

  def and_i_see_the_updated_lead_partner
    expect(confirm_schools_page).to have_content(my_lead_partner_name)
  end

  def and_i_see_the_updated_employing_school
    expect(confirm_schools_page).to have_content(my_employing_school_name)
  end
end

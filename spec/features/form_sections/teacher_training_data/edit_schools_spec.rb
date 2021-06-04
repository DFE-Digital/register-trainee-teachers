# frozen_string_literal: true

require "rails_helper"

RSpec.feature "edit schools spec", type: :feature do
  context "as a school direct salaried trn_submitted trainee" do
    before do
      given_i_am_authenticated
      given_a_school_direct_salaried_trainee_submitted_for_trn_exists
      and_a_number_of_lead_schools_exist
      and_a_number_of_employing_schools_exist
      and_i_visit_the_trainee_record_page
    end

    scenario "changing the lead school", js: true do
      i_click_on_change_school(:lead_school)
      and_i_am_on_the_edit_lead_school_page
      and_i_fill_in_my_lead_school
      and_i_click_the_first_item_in_the_list_lead_school
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
    end

    scenario "changing the employing school", js: true do
      i_click_on_change_school(:employing_school)
      and_i_am_on_the_edit_employing_school_page
      and_i_fill_in_my_employing_school
      and_i_click_the_first_item_in_the_list_employing_school
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
    end
  end

  context "as a school direct tuition fee trn_submitted trainee" do
    before do
      given_i_am_authenticated
      given_a_school_direct_tuition_fee_trainee_submitted_for_trn_exists
      and_a_number_of_lead_schools_exist
      and_a_number_of_employing_schools_exist
      and_i_visit_the_trainee_record_page
    end

    scenario "changing the lead school", js: true do
      i_click_on_change_school(:lead_school)
      and_i_am_on_the_edit_lead_school_page
      and_i_fill_in_my_lead_school
      and_i_click_the_first_item_in_the_list_lead_school
      and_i_continue
      then_i_am_redirected_to_the_confirm_schools_page
    end
  end

private

  def given_a_school_direct_salaried_trainee_submitted_for_trn_exists
    given_a_trainee_exists(:completed, :school_direct_salaried, :with_lead_school, :with_employing_school, :submitted_for_trn)
  end

  def given_a_school_direct_tuition_fee_trainee_submitted_for_trn_exists
    given_a_trainee_exists(:completed, :school_direct_tuition_fee, :with_lead_school, :submitted_for_trn)
  end

  def and_i_fill_in_my_lead_school
    edit_lead_school_page.lead_school.fill_in with: my_lead_school_name
  end

  def and_i_fill_in_my_employing_school
    edit_employing_school_page.employing_school.fill_in with: my_employing_school_name
  end

  def and_i_am_on_the_edit_lead_school_page
    expect(edit_lead_school_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_i_am_on_the_edit_employing_school_page
    expect(edit_employing_school_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_i_click_the_first_item_in_the_list_lead_school
    click(edit_lead_school_page.autocomplete_list_item)
  end

  def and_i_click_the_first_item_in_the_list_employing_school
    click(edit_employing_school_page.autocomplete_list_item)
  end

  def and_i_continue
    click(edit_lead_school_page.submit)
  end

  def and_a_number_of_lead_schools_exist
    @lead_schools = create_list(:school, 1, :lead)
  end

  def and_a_number_of_employing_schools_exist
    @employing_schools = create_list(:school, 1)
  end

  def and_i_visit_the_trainee_record_page
    record_page.load(id: trainee.slug)
  end

  def my_lead_school_name
    my_lead_school.name.split(" ").first
  end

  def my_employing_school_name
    my_employing_school.name.split(" ").first
  end

  def my_lead_school
    @my_lead_school ||= @lead_schools.sample
  end

  def my_employing_school
    @my_employing_school ||= @employing_schools.sample
  end

  def then_i_am_redirected_to_the_confirm_lead_school_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_lead_schools_page_filtered_by_my_query
    expect(lead_schools_search_page).to be_displayed(trainee_id: trainee.slug, query: my_lead_school_name)
  end

  def i_click_on_change_school(school)
    record_page.public_send("change_#{school}").click
  end

  def then_i_am_redirected_to_the_confirm_schools_page
    expect(confirm_schools_page).to be_displayed(id: trainee.slug)
  end
end

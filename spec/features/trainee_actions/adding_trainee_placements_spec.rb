# frozen_string_literal: true

require "rails_helper"

feature "Add a placement" do
  scenario "Add a new placement to an existing trainee" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_a_school_exists

    when_i_navigate_to_the_new_placement_form
    then_i_see_the_not_found_page

    when_the_feature_flag_is_active
    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_new_placement_has_been_created

    when_i_navigate_to_the_new_placement_form
    then_i_see_the_second_new_placement_form

    when_i_enter_details_for_a_new_school
    and_i_click_continue
    then_i_see_the_second_new_placement_has_been_created
  end

private

  def and_a_trainee_exists_with_trn_received
    @trainee ||= given_a_trainee_exists(:trn_received)
  end

  def and_a_school_exists
    @school ||= create(:school)
  end

  def when_i_navigate_to_the_new_placement_form
    visit new_trainee_placements_path(trainee_id: @trainee.slug)
  end
  alias_method :and_i_navigate_to_the_new_placement_form, :when_i_navigate_to_the_new_placement_form

  def then_i_see_the_not_found_page
    expect(page).to have_current_path(not_found_path)
  end

  def when_the_feature_flag_is_active
    enable_features(:trainee_placement)
  end

  def then_i_see_the_new_placement_form
    expect(page).to have_content("First placement")
  end

  def then_i_see_the_second_new_placement_form
    expect(page).to have_content("Second placement")
  end

  def when_i_select_an_existing_school
    find(:xpath, "//input[@name='placement[school_id]']", visible: false).set(@school.id)
  end

  def and_i_click_continue
    click_button "Continue"
  end

  def then_i_see_the_new_placement_has_been_created
    expect(page).to have_content("First placement")
    expect(page).to have_content(@school.name)
    expect(page).to have_content(@school.postcode)
    expect(page).to have_content("URN #{@school.urn}")
  end

  def when_i_enter_details_for_a_new_school
    fill_in("School or setting name", with: "St. Alice's Primary School", visible: false)
    fill_in("School unique reference number (URN) - if it has one", with: "654321", visible: false)
    fill_in("Postcode", with: "OX1 1AA", visible: false)
  end

  def then_i_see_the_second_new_placement_has_been_created
    expect(page).to have_content("Second placement")
    expect(page).to have_content("St. Alice's Primary School")
    expect(page).to have_content("OX1 1AA")
    expect(page).to have_content("URN 654321")
  end
end

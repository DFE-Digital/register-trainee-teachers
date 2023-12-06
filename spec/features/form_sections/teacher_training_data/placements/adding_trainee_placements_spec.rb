# frozen_string_literal: true

require "rails_helper"

feature "Add a placement" do
  after do
    FormStore.clear_all(@trainee.id) if @trainee.present?
  end

  scenario "Attempt to add new placement when feature flag is inactive", feature_trainee_placement: false do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_a_school_exists

    when_i_navigate_to_the_new_placement_form
    then_i_see_the_not_found_page
  end

  scenario "Add one new placement to an existing trainee", feature_trainee_placement: true do
    given_i_am_authenticated
    and_a_postgrad_trainee_exists_with_trn_received
    and_a_school_exists
    and_i_navigate_to_the_trainee_dashboard
    and_i_click_to_enter_first_placement
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_new_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_update
    then_i_see_a_flash_message
    and_a_new_placement_is_created
  end

  scenario "Add two new placements to an existing trainee", feature_trainee_placement: true do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_a_school_exists
    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_new_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_add_a_placement
    then_i_see_the_second_new_placement_form

    when_i_enter_details_for_a_new_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_second_new_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_update
    then_i_see_a_flash_message
    and_two_new_placements_are_created

    when_i_revisit_the_placements_confirmation_page
    and_i_click_update
    and_no_new_placements_are_created

    then_i_see_the_trainee_page
  end

private

  def then_i_see_the_trainee_page
    expect(page).to have_current_path(trainee_path(trainee))
  end

  def and_a_trainee_exists_with_trn_received
    @trainee ||= given_a_trainee_exists(:trn_received)
    FormStore.clear_all(@trainee.id)
  end

  def and_a_postgrad_trainee_exists_with_trn_received
    @trainee ||= given_a_trainee_exists(:trn_received, :early_years_postgrad)
    FormStore.clear_all(@trainee.id)
  end

  def and_a_school_exists
    @school ||= create(:school)
  end

  def and_i_navigate_to_the_trainee_dashboard
    visit trainee_path(trainee)
  end

  def and_i_click_to_enter_first_placement
    click_link "Enter first placement"
  end

  def when_i_navigate_to_the_new_placement_form
    visit new_trainee_placement_path(trainee_id: @trainee.slug)
  end
  alias_method :and_i_navigate_to_the_new_placement_form, :when_i_navigate_to_the_new_placement_form

  def then_i_see_the_not_found_page
    expect(page).to have_current_path(not_found_path)
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

  def when_i_click_add_a_placement
    click_link "Add a placement"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end

  def and_i_see_the_new_placement_ready_for_confirmation
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

  def and_i_see_the_second_new_placement_ready_for_confirmation
    expect(page).to have_content("Second placement")
    expect(page).to have_content("St. Alice's Primary School")
    expect(page).to have_content("OX1 1AA")
    expect(page).to have_content("URN 654321")
  end

  def when_i_click_update
    click_button "Update record"
  end
  alias_method :and_i_click_update, :when_i_click_update

  def then_i_see_a_flash_message
    expect(page).to have_content("Trainee placement details updated")
  end

  def and_no_placements_are_created
    expect(@trainee.reload.placements.count).to eq(0)
  end

  def and_a_new_placement_is_created
    expect(@trainee.reload.placements.count).to eq(1)
  end

  def and_two_new_placements_are_created
    expect(@trainee.reload.placements.count).to eq(2)
  end
  alias_method :and_no_new_placements_are_created, :and_two_new_placements_are_created

  def when_i_revisit_the_placements_confirmation_page
    visit trainee_placements_confirm_path(trainee_id: @trainee.slug)
  end
end

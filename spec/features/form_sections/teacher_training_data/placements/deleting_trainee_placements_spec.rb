# frozen_string_literal: true

require "rails_helper"

feature "Delete a placement" do
  after do
    FormStore.clear_all(@trainee.id)
  end

  scenario "Delete a placement from an existing trainee" do
    given_i_am_authenticated
    and_a_trainee_exists_with_a_placement

    and_i_navigate_to_the_delete_placement_form
    then_i_see_the_delete_placement_form

    when_i_click_cancel
    then_the_placement_is_not_deleted

    when_i_visit_the_trainee_path_and_navigate_to_the_delete_placement_form
    and_i_click_the_confirm_button
    then_i_see_the_confirmation_page
    and_the_deleted_placement_is_no_longer_visible
    and_is_not_yet_deleted

    when_i_click_update
    then_the_placement_is_deleted
    and_i_see_a_flash_message
  end

  scenario "Delete an unsaved placement from an existing trainee" do
    given_i_am_authenticated
    and_a_trainee_exists
    and_a_school_exists

    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_new_placement_ready_for_confirmation
    and_no_placements_are_created

    and_i_click_the_delete_placement_link
    then_i_see_the_delete_placement_form

    and_i_click_the_confirm_button
    then_i_see_the_confirmation_page
    and_the_deleted_placement_is_no_longer_visible
    and_no_placements_are_created
    and_i_see_a_placement_removed_flash_message
  end

private

  def and_a_trainee_exists
    @trainee = given_a_trainee_exists(:trn_received, :provider_led_postgrad)
    FormStore.clear_all(@trainee.id)
  end

  def and_a_school_exists
    @school ||= create(:school)
  end

  def and_a_trainee_exists_with_a_placement
    and_a_trainee_exists
    @placement = create(:placement, :with_school, trainee: @trainee)
    @school ||= @placement.school
    FormStore.clear_all(@trainee.id)
  end

  def when_i_navigate_to_the_delete_placement_form
    visit delete_trainee_placement_path(trainee_id: @trainee.slug, id: @placement.slug)
  end
  alias_method :and_i_navigate_to_the_delete_placement_form, :when_i_navigate_to_the_delete_placement_form

  def when_i_visit_the_trainee_path_and_navigate_to_the_delete_placement_form
    visit trainee_path(id: @trainee.slug)
    click_on "Manage placements"
    click_on "Remove placement"
  end

  def then_i_see_the_delete_placement_form
    expect(page).to have_content("Are you sure you want to delete this placement?")
  end

  def when_i_click_cancel
    click_on "Cancel"
  end

  def then_the_placement_is_not_deleted
    expect(Placement.find_by(id: @placement.id)).to be_present
  end
  alias_method :and_is_not_yet_deleted, :then_the_placement_is_not_deleted

  def then_the_placement_is_deleted
    expect(Placement.find_by(id: @placement.id)).not_to be_present
  end

  def and_i_click_the_confirm_button
    click_on "Yes I’m sure — delete this placement"
  end

  def when_i_click_update
    click_on "Update record"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end

  def and_the_deleted_placement_is_no_longer_visible
    expect(page).not_to have_content(@school.name)
  end

  def and_i_see_a_flash_message
    expect(page).to have_content("Trainee placement details updated")
  end

  def and_i_navigate_to_the_new_placement_form
    visit new_trainee_placement_path(trainee_id: @trainee.slug)
  end

  def then_i_see_the_new_placement_form
    expect(page).to have_content("First placement")
  end

  def when_i_select_an_existing_school
    find(:xpath, "//input[@name='placement[school_id]']", visible: false).set(@school.id)
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_see_the_new_placement_ready_for_confirmation
    expect(page).to have_content("First placement")
    expect(page).to have_content(@school.name)
    expect(page).to have_content(@school.postcode)
    expect(page).to have_content("URN #{@school.urn}")
  end

  def and_no_placements_are_created
    expect(@trainee.reload.placements.count).to eq(0)
  end

  def and_i_click_the_delete_placement_link
    click_on "Remove placement"
  end

  def and_i_see_a_placement_removed_flash_message
    expect(page).to have_content("Placement removed")
  end
end

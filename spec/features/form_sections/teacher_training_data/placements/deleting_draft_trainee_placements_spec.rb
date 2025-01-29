# frozen_string_literal: true

require "rails_helper"

feature "Delete a placement" do
  after do
    FormStore.clear_all(@trainee.id)
  end

  scenario "Delete a placement from an existing trainee" do
    given_i_am_authenticated
    and_a_draft_trainee_exists_with_a_placement

    and_i_navigate_to_the_delete_placement_form
    then_i_see_the_delete_placement_form

    when_i_click_cancel
    then_the_placement_is_not_deleted

    when_i_visit_the_trainee_path_and_navigate_to_the_delete_placement_form
    and_i_click_the_confirm_button
    then_i_see_the_confirmation_page
    and_the_deleted_placement_is_no_longer_visible
    and_the_placement_is_deleted
    and_i_see_a_flash_message
  end

private

  def and_a_draft_trainee_exists_with_a_placement
    @trainee = given_a_trainee_exists(
      :trn_received,
      :provider_led_postgrad,
      :draft,
      placement_detail: PLACEMENT_DETAIL_ENUMS[:has_placement_detail],
    )
    @placement = create(:placement, trainee: @trainee)
    FormStore.clear_all(@trainee.id)
  end

  def when_i_navigate_to_the_delete_placement_form
    visit delete_trainee_placement_path(trainee_id: @trainee.slug, id: @placement.slug)
  end
  alias_method :and_i_navigate_to_the_delete_placement_form, :when_i_navigate_to_the_delete_placement_form

  def when_i_visit_the_trainee_path_and_navigate_to_the_delete_placement_form
    visit trainee_path(id: @trainee.slug)
    click_on "Placements"
    click_on "Remove placement"
  end

  def then_i_see_the_delete_placement_form
    expect(page).to have_content("Are you sure you want to remove this placement?")
  end

  def when_i_click_cancel
    click_on "Cancel"
  end

  def then_the_placement_is_not_deleted
    expect(Placement.find_by(id: @placement.id)).to be_present
  end

  def and_the_placement_is_deleted
    expect(Placement.find_by(id: @placement.id)).not_to be_present
  end

  def and_i_click_the_confirm_button
    click_on "Yes I’m sure — remove this placement"
  end

  def when_i_click_update
    click_on "Update record"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end

  def and_the_deleted_placement_is_no_longer_visible
    expect(page).not_to have_content(@placement.name)
  end

  def and_i_see_a_flash_message
    expect(page).to have_content("Placement removed")
  end
end

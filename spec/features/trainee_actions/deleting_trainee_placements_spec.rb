# frozen_string_literal: true

require "rails_helper"

feature "Delete a placement" do
  scenario "Delete a placement from an existing trainee" do
    given_i_am_authenticated
    and_a_trainee_exists_with_a_placement

    when_i_navigate_to_the_delete_placement_form
    then_i_see_the_not_found_page

    when_the_feature_flag_is_active
    and_i_navigate_to_the_delete_placement_form
    then_i_see_the_delete_placement_form

    when_i_click_cancel
    then_the_placement_is_not_deleted

    when_i_navigate_to_the_delete_placement_form
    and_i_click_the_confirm_button
    then_the_placement_is_deleted
    and_i_see_a_flash_message
  end

private

  def and_a_trainee_exists_with_a_placement
    @trainee = given_a_trainee_exists(:trn_received)
    @placement = create(:placement, trainee: @trainee)
  end

  def when_i_navigate_to_the_delete_placement_form
    visit destroy_trainee_placement_path(trainee_id: @trainee.slug, id: @placement.id)
  end
  alias_method :and_i_navigate_to_the_delete_placement_form, :when_i_navigate_to_the_delete_placement_form

  def then_i_see_the_not_found_page
    expect(page).to have_current_path(not_found_path)
  end

  def when_the_feature_flag_is_active
    enable_features(:trainee_placement)
  end

  def then_i_see_the_delete_placement_form
    expect(page).to have_content("Are you sure you want to delete this placement?")
  end

  def and_i_click_cancel
    click_link "Cancel"
  end

  def then_the_placement_is_not_deleted
    expect(Placement.find_by(id: @placement.id)).to be_present
  end

  def then_the_placement_is_deleted
    expect(Placement.find_by(id: @placement.id)).not_to be_present
  end

  def and_i_click_the_confirm_button
    click_button "Yes I’m sure — delete this placement"
  end

  def and_i_see_a_flash_message
    expect(page).to have_content("Placement deleted")
  end
end

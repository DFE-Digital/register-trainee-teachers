# frozen_string_literal: true

require "rails_helper"

feature "Add a placement", feature_trainee_placement: true do
  scenario "Add a new placement to an existing trainee" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received

    when_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form
  end

private

  def and_a_trainee_exists_with_trn_received
    @trainee ||= given_a_trainee_exists(:trn_received)
  end

  def when_i_navigate_to_the_new_placement_form
    visit new_trainee_placements_path(trainee_id: @trainee.slug)
  end

  def then_i_see_the_new_placement_form
    expect(page).to have_content("First placement")
  end
end

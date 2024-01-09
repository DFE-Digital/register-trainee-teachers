# frozen_string_literal: true

require "rails_helper"

feature "Editing a placement" do
  background do
    given_i_am_authenticated
  end

  after do
    FormStore.clear_all(@trainee.id)
  end

  context "draft trainee" do
    scenario "editing an existing placement" do
      given_a_trainee_exists(:draft)

      given_i_have_one_placement
      and_a_school_exists

      and_i_am_on_the_confirm_placement_details_page
      when_i_click_on_the_change_link
      then_i_am_taken_to_the_placement_edit_page
      and_it_is_prepopulated_with_existing_placement
      when_i_select_an_existing_school

      and_i_click_continue
      then_i_see_the_confirmation_page
      and_i_see_the_updated_placement
    end
  end

  context "non draft trainee" do
    scenario "editing an existing placement" do
      given_a_trainee_exists(:submitted_for_trn)

      given_i_have_one_placement
      and_two_schools_exist

      and_i_am_on_the_confirm_placement_details_page
      when_i_click_on_the_change_link
      then_i_am_taken_to_the_placement_edit_page
      and_it_is_prepopulated_with_existing_placement
      when_i_select_an_existing_school

      and_i_click_continue
      then_i_see_the_confirmation_page
      and_i_see_the_updated_placement
    end

    scenario "editing a stashed new placement" do
      given_a_trainee_exists(:submitted_for_trn)
      and_two_schools_exist
      and_i_am_on_the_confirm_placement_details_page
      and_i_click_on_add_a_placement_button
      and_i_am_on_the_add_placement_page
      and_i_select_an_existing_school
      and_i_click_continue
      and_i_see_the_confirmation_page
      and_i_see_the_updated_placement
      and_no_placements_are_created

      when_i_click_on_the_change_link
      and_it_is_prepopulated_with_existing_placement(school: school_one)
      and_i_select_an_existing_school(school: school_two)
      and_i_click_continue

      then_i_see_the_confirmation_page
      and_i_see_the_updated_placement(school: school_two)
      and_i_see_only_one_placement
      and_no_placements_are_created
      and_i_click_update
      and_one_placement_are_created
    end
  end

private

  def and_it_is_prepopulated_with_existing_placement(school: trainee.placements.first.school)
    expect(page.find_by_id("schools-autocomplete-element")["data-default-value"]).to have_text(school.name)
  end

  def and_i_am_on_the_confirm_placement_details_page
    visit "/trainees/#{trainee.slug}/placements/confirm"
  end

  def then_i_am_taken_to_the_placement_edit_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/placements/#{trainee.placements.first.slug}/edit")
  end

  def when_i_click_on_the_change_link
    page.click_on("Change")
  end

  def given_i_have_one_placement
    create(:placement, trainee:)
  end

  def school_one
    @school_one ||= create(:school)
  end

  def school_two
    @school_two ||= create(:school)
  end
  alias_method :and_a_school_exists, :school_one

  def and_two_schools_exist
    school_one
    school_two
  end

  def and_i_am_on_the_add_placement_page
    expect(page).to have_current_path("/trainees/#{trainee.slug}/placements/new")
  end

  def when_i_select_an_existing_school(school: school_one)
    find(:xpath, "//input[@name='placement[school_id]']", visible: false).set(school.id)
  end
  alias_method :and_i_select_an_existing_school, :when_i_select_an_existing_school

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_click_on_add_a_placement_button
    page.click_on("Add a placement", class: "govuk-button--secondary govuk-button")
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end
  alias_method :and_i_see_the_confirmation_page, :then_i_see_the_confirmation_page

  def and_i_see_the_updated_placement(school: school_one)
    expect(page).to have_content("First placement")
    expect(page).to have_content(school.name)
    expect(page).to have_content(school.postcode)
    expect(page).to have_content("URN #{school.urn}")
  end

  def and_i_see_only_one_placement
    expect(page).to have_css(".app-summary-card", count: 1)
  end

  def and_no_placements_are_created
    expect(trainee.reload.placements.count).to eq(0)
  end

  def and_i_click_update
    click_on "Update record"
  end

  def and_one_placement_are_created
    expect(trainee.reload.placements.count).to eq(1)
  end
end

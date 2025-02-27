# frozen_string_literal: true

require "rails_helper"

feature "Add a placement" do
  after do
    FormStore.clear_all(@trainee.id) if @trainee.present?
  end

  shared_examples "adding a placement" do |trait|
    scenario "Add a new placement to an existing trainee in the #{trait} state" do
      given_i_am_authenticated
      and_a_postgrad_trainee_exists_with(trait)
      and_two_schools_exist
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
  end

  shared_examples "adding a placement with non-JS flow" do |trait|
    scenario "Add a new placement to an existing trainee in the #{trait} state" do
      given_i_am_authenticated
      and_a_postgrad_trainee_exists_with(trait)
      and_two_schools_exist
      and_two_other_schools_exist
      and_i_navigate_to_the_trainee_dashboard
      and_i_click_to_enter_first_placement
      then_i_see_the_new_placement_form

      when_i_enter_a_non_matching_search_for_a_school
      and_i_click_continue
      then_i_see_the_no_search_results_page

      when_i_click_back_to_the_new_placement_page
      and_i_click_continue

      when_i_enter_a_search_for_a_school
      and_i_click_continue
      then_i_see_the_search_results_page

      when_i_click_continue
      then_i_see_an_error_message

      when_i_select_an_existing_school_from_the_search_results
      and_i_click_continue
      then_i_see_the_confirmation_page
      and_i_see_the_new_placement_ready_for_confirmation
      and_no_placements_are_created

      when_i_click_update
      then_i_see_a_flash_message
      and_a_new_placement_is_created
    end
  end

  %i[trn_received qts_recommended qts_awarded].each do |trait|
    context "with a #{trait} state" do
      it_behaves_like "adding a placement", trait
      it_behaves_like "adding a placement with non-JS flow", trait
    end
  end

  scenario "Add two new placements to an existing trainee with the details of a new school" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_two_schools_exist
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

  scenario "Add two new placements to an existing trainee with schools that exist" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_two_schools_exist
    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_new_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_add_a_placement
    then_i_see_the_second_new_placement_form

    when_i_select_another_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_other_existing_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_update
    then_i_see_a_flash_message
    and_two_new_placements_are_created

    when_i_revisit_the_placements_confirmation_page
    and_i_click_update
    and_no_new_placements_are_created

    then_i_see_the_trainee_page
  end

  scenario "Add two new placements to an existing trainee to the same school that exists" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received

    and_two_schools_exist
    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_new_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_add_a_placement
    then_i_see_the_second_new_placement_form

    when_i_select_an_existing_school
    and_i_click_continue
    then_i_see_the_confirmation_page
    and_i_see_the_second_placement_ready_for_confirmation
    and_no_placements_are_created

    when_i_click_update
    then_i_see_a_flash_message
    and_two_new_placements_are_created

    when_i_revisit_the_placements_confirmation_page
    and_i_click_update
    and_no_new_placements_are_created

    then_i_see_the_trainee_page
  end

  scenario "Add two new placements to an existing trainee to the same new school" do
    given_i_am_authenticated
    and_a_trainee_exists_with_trn_received
    and_i_navigate_to_the_new_placement_form
    then_i_see_the_new_placement_form

    when_i_enter_details_for_a_new_school
    and_i_click_continue

    then_i_see_the_confirmation_page
    and_i_see_the_first_placement_ready_for_confirmation
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

  def and_a_postgrad_trainee_exists_with(trait)
    @trainee ||= given_a_trainee_exists(trait, :early_years_postgrad)
    FormStore.clear_all(@trainee.id)
  end

  def and_a_trainee_exists_with_trn_received
    @trainee ||= given_a_trainee_exists(:trn_received)
    FormStore.clear_all(@trainee.id)
  end

  def and_two_schools_exist
    @school ||= create(:school, name: "London School for Children")
    @other_school ||= create(:school, name: "Edinburgh School for Infants")
  end

  def and_two_other_schools_exist
    create(:school, name: "Cardiff College for Teenagers")
    create(:school, name: "Edinburgh Academy for Infants")
  end

  def and_i_navigate_to_the_trainee_dashboard
    visit trainee_path(trainee)
  end

  def and_i_click_to_enter_first_placement
    click_on "Enter first placement"
  end

  def when_i_navigate_to_the_new_placement_form
    visit new_trainee_placement_path(trainee_id: @trainee.slug)
  end
  alias_method :and_i_navigate_to_the_new_placement_form, :when_i_navigate_to_the_new_placement_form

  def then_i_see_the_new_placement_form
    expect(page).to have_content("First placement")
  end

  def then_i_see_the_second_new_placement_form
    expect(page).to have_content("Second placement")
  end

  def when_i_select_an_existing_school
    find(:xpath, "//input[@name='placement[school_id]']", visible: false).set(@school.id)
  end

  def when_i_select_another_existing_school
    find(:xpath, "//input[@name='placement[school_id]']", visible: false).set(@other_school.id)
  end

  def and_i_click_continue
    click_on "Continue"
  end
  alias_method :when_i_click_continue, :and_i_click_continue

  def when_i_click_add_a_placement
    click_on "Add a placement"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_current_path(trainee_placements_confirm_path(trainee_id: @trainee.slug))
    expect(page).to have_content("Confirm placement details")
  end

  def and_i_see_the_new_placement_ready_for_confirmation
    expect(page).to have_content("First placement")

    within("#school-or-setting-1") do
      expect(page).to have_content(@school.name)
      expect(page).to have_content(@school.postcode)
      expect(page).to have_content("URN #{@school.urn}")
    end
  end

  def and_i_see_the_second_placement_ready_for_confirmation
    expect(page).to have_content("Second placement")

    within("#school-or-setting-2") do
      expect(page).to have_content(@school.name)
      expect(page).to have_content(@school.postcode)
      expect(page).to have_content("URN #{@school.urn}")
    end
  end

  def when_i_enter_details_for_a_new_school
    fill_in("School or setting name", with: "St. Alice's Primary School", visible: false)
    fill_in("School unique reference number (URN) - if it has one", with: "654321", visible: false)
    fill_in("Postcode", with: "OX1 1AA", visible: false)
  end

  def and_i_see_the_first_placement_ready_for_confirmation
    expect(page).to have_content("First placement")

    within("#school-or-setting-1") do
      expect(page).to have_content("St. Alice's Primary School")
      expect(page).to have_content("OX1 1AA")
      expect(page).to have_content("URN 654321")
    end
  end

  def and_i_see_the_second_new_placement_ready_for_confirmation
    expect(page).to have_content("Second placement")
    expect(page).to have_content("St. Alice's Primary School")
    expect(page).to have_content("OX1 1AA")
    expect(page).to have_content("URN 654321")
  end

  def and_i_see_the_other_existing_placement_ready_for_confirmation
    expect(page).to have_content("Edinburgh School")
  end

  def when_i_click_update
    click_on "Update record"
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

  def when_i_enter_a_non_matching_search_for_a_school
    fill_in(
      "Search for a school by its unique reference number (URN), name or postcode",
      with: "Birmingham",
    )
  end

  def then_i_see_the_no_search_results_page
    expect(page).to have_content("No results found for ‘Birmingham’")
  end

  def when_i_click_back_to_the_new_placement_page
    click_on "Change your search"
  end

  def then_i_see_an_error_message
    expect(page).to have_current_path(
      trainee_placement_school_search_index_path(trainee_id: @trainee.slug),
    )
    expect(page).to have_content("Select a placement school")
  end

  def when_i_enter_a_search_for_a_school
    fill_in(
      "Search for a school by its unique reference number (URN), name or postcode",
      with: "Lond",
    )
  end

  def then_i_see_the_search_results_page
    expect(page).to have_current_path(
      new_trainee_placement_school_search_path(trainee_id: @trainee.slug, school_search: "Lond"),
    )
    expect(page).to have_content("1 result found")
    expect(page).to have_content("Change your search if the school you’re looking for is not listed")
    expect(page).to have_content("London School for Children")
    expect(page).not_to have_content("Cardiff College for Teenagers")
    expect(page).not_to have_content("Edinburgh Academy for Infants")
  end

  def when_i_select_an_existing_school_from_the_search_results
    choose("London School for Children")
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "bulk update page" do
  before do
    given_i_am_authenticated
  end

  context "there are placements to bulk upload" do
    before do
      given_a_trainee_exists(:without_required_placements)
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk placement section is visible" do
      then_i_see_how_many_trainees_i_can_bulk_update
      and_i_see_the_placement_data_link
    end
  end

  context "there are no placements to bulk upload" do
    before do
      given_a_trainee_exists(:with_placements)
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk placement section is not visible" do
      then_i_do_not_see_the_bulk_placement_section
    end
  end

  context "salaried route trainee with one placement" do
    before do
      given_a_salaried_trainee_with_one_placement
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk placement section is visible" do
      then_i_see_how_many_trainees_i_can_bulk_update
    end
  end

  context "there are trainees to bulk recommend" do
    before do
      given_two_trainees_exist_to_recommend
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk change status section is visible" do
      then_i_see_how_many_trainees_i_can_bulk_recommend
      then_i_see_the_bulk_recommend_link
    end
  end

  context "there are no trainees to bulk recommend" do
    before do
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk change status section is visible" do
      then_i_do_not_see_the_bulk_recommend_link
    end
  end

private

  def and_i_visit_the_bulk_update_page
    visit bulk_update_path
  end

  def then_i_see_how_many_trainees_i_can_bulk_update
    expect(page).to have_content("You have 1 trainee record who do not have the required number of placements.")
  end

  def then_i_see_how_many_trainees_i_can_bulk_recommend
    expect(page).to have_content("You can update the status of 2 trainees")
  end

  def and_i_see_the_placement_data_link
    expect(page).to have_link("Bulk add missing placement data to trainee records", href: new_bulk_update_placements_path)
  end

  def then_i_see_the_bulk_recommend_link
    expect(page).to have_link("Change trainee status in bulk", href: new_bulk_update_recommendations_upload_path)
  end

  def then_i_do_not_see_the_bulk_placement_section
    expect(page).not_to have_content("Add missing placement data")
  end

  def then_i_do_not_see_the_bulk_recommend_link
    expect(page).to have_content("You do not have any trainees eligible for a QTS or EYTS status change at the moment")
  end

  def given_a_salaried_trainee_with_one_placement
    trainee = create(
      :trainee,
      :without_required_placements,
      training_route: TRAINING_ROUTE_ENUMS[:school_direct_salaried],
      provider: current_user.organisation,
    )
    create(:placement, trainee:)
  end

  def given_two_trainees_exist_to_recommend
    @trainees = [
      create(:trainee, :trn_received, trn: "2413295", itt_end_date: Time.zone.today, provider: current_user.organisation),
      create(:trainee, :trn_received, trn: "4814731", itt_end_date: Time.zone.today + 1.month, provider: current_user.organisation),
    ]
  end
end

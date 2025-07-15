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

  context "there are trainees to bulk recommend" do
    before do
      given_two_trainees_exist_to_recommend
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk recommend section is visible" do
      then_i_see_how_many_trainees_i_can_bulk_recommend
      then_i_see_the_bulk_recommend_link
    end
  end

  context "there are no trainees to bulk recommend" do
    before do
      and_i_visit_the_bulk_update_page
    end

    scenario "the bulk recommend section is visible" do
      then_i_do_not_see_the_bulk_recommend_link
    end
  end

private

  def and_i_visit_the_bulk_update_page
    visit bulk_update_path
  end

  def then_i_see_how_many_trainees_i_can_bulk_update
    expect(page).to have_content("You can bulk add missing placement data to 1 trainee record")
  end

  def then_i_see_how_many_trainees_i_can_bulk_recommend
    expect(page).to have_content("You have 2 trainees that can be selected to hold QTS or EYTS")
  end

  def and_i_see_the_placement_data_link
    expect(page).to have_link("Bulk add missing placement data to trainee records", href: new_bulk_update_placements_path)
  end

  def then_i_see_the_bulk_recommend_link
    expect(page).to have_link("Bulk select trainees for QTS or EYTS", href: new_bulk_update_recommendations_upload_path)
  end

  def then_i_do_not_see_the_bulk_placement_section
    expect(page).not_to have_content("Add missing placement data")
  end

  def then_i_do_not_see_the_bulk_recommend_link
    expect(page).to have_content("You do not have any trainees who can be bulk selected that now hold qualified teacher status (QTS) or early years teacher status (EYTS)")
  end

  def given_two_trainees_exist_to_recommend
    @trainees = [
      create(:trainee, :trn_received, trn: "2413295", itt_end_date: Time.zone.today, provider: current_user.organisation),
      create(:trainee, :trn_received, trn: "4814731", itt_end_date: Time.zone.today + 1.month, provider: current_user.organisation),
    ]
  end
end

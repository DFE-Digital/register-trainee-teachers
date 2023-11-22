# frozen_string_literal: true

require "rails_helper"

feature "bulk update page", feature_bulk_placements: true do
  before do
    given_i_am_authenticated
    given_there_are_trainees_without_placements
    and_i_visit_the_bulk_placements_page
  end

  scenario "viewing the download instructions" do
    then_i_see_how_many_trainees_i_can_bulk_update
    and_i_see_a_filename_of_the_file_need_to_download
  end

private

  def then_i_see_how_many_trainees_i_can_bulk_update
    expect(page).to have_content("2 that can be bulk updated")
  end

  def and_i_see_a_filename_of_the_file_need_to_download
    expect(page).to have_content("#{filename}-to-add-missing-prepopulated.csv")
  end

  def given_there_are_trainees_without_placements
    create_list(:trainee, 2, provider: current_user.organisation)
  end

  def and_i_visit_the_bulk_placements_page
    visit new_bulk_update_placements_path
  end

  def filename
    current_user.organisation.name.parameterize
  end
end

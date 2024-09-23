# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  before do
    given_i_am_authenticated
  end

  before do
    and_i_visit_the_bulk_add_trainees_page
  end

  scenario "the bulk add trainees page is visible" do
    then_i_see_how_instructions_on_how_to_bulk_add_trainees
    and_i_see_the_empty_csv_link
  end

private

  def and_i_visit_the_bulk_add_trainees_page
    visit bulk_update_trainees_add_new_trainees_path
  end

  def then_i_see_how_instructions_on_how_to_bulk_add_trainees
    expect(page).to have_content("Bulk add new trainees")
  end

  def and_i_see_the_empty_csv_link
    expect(page).to have_link("Download empty CSV file to add new trainees")
  end
end

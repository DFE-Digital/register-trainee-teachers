# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees" do
  before do
    given_i_am_authenticated
  end

  before do
    and_i_visit_the_bulk_upload_trainees_page
  end

  scenario "the bulk upload trainees page is visible" do
    then_i_see_how_instructions_on_how_to_bulk_upload_trainees
    and_i_see_the_upload_trainees_link
  end

private

  def and_i_visit_the_bulk_upload_trainees_page
    visit bulk_upload_trainees_path
  end

  def then_i_see_how_instructions_on_how_to_bulk_upload_trainees
    expect(page).to have_content("Bulk add new trainees")
  end

  def and_i_see_the_upload_trainees_link
    expect(page).to have_link("Download empty CSV file to add new trainees")
  end
end

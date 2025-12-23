# frozen_string_literal: true

require "rails_helper"

feature "Reference data download 2026", js: true do
  include FileHelper

  scenario "navigate to Reference data" do
    when_i_open_a_2026_0_reference_data_page
    and_i_click_on_the_download_link
    then_i_receive_the_data_entries_as_a_file
  end

private

  def when_i_open_a_2026_0_reference_data_page
    visit "/reference-data/v2026.0/course-age-range"
  end

  def and_i_click_on_the_download_link
    click_link "Download entries as a CSV file"
  end

  def then_i_receive_the_data_entries_as_a_file
    expect(download_filename).to eq("course-age-range-v2026.0.csv")
    expect(parsed_download_content).to eq(parsed_course_age_range_file)
  end

  def parsed_download_content
    CSV.parse(download_content, headers: true).map(&:to_h)
  end

  def parsed_course_age_range_file
    CSV.parse(file_content("reference_data/v2026_0/course_age_range.csv"), headers: true).map(&:to_h)
  end
end

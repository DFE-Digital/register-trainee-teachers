# frozen_string_literal: true

require "rails_helper"

feature "Reference data download 2026", js: true do
  include FileHelper

  scenario "navigate to Reference data" do
    # 2026 reference data is hidden at the time of writing, otherwise we would navigate to it like in the 2025 test
    when_i_click_on_the_download_entries_link
    then_i_receive_the_data_entries_as_a_file
  end

private

  def when_i_click_on_the_download_entries_link
    visit reference_datum_download_path(
      reference_data_version: "v2026.0",
      reference_datum_attribute: "course_age_range",
    )
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

# frozen_string_literal: true

require "rails_helper"

feature "Reference data download", js: true do
  include FileHelper

  background do
    given_i_am_on_the_reference_data_page
  end

  scenario "navigate to Reference data" do
    when_i_click_on_the_v2025_0_rc_link
    and_i_click_on_the_course_age_range_link
    and_i_see_the_course_age_range_data
    and_i_click_on_the_download_entries_link
    then_i_receive_the_data_entries_as_a_file
  end

private

  def given_i_am_on_the_reference_data_page
    reference_data_page.load
  end

  def when_i_click_on_the_v2025_0_rc_link
    reference_data_page.v20250Rc_link.click
  end

  def and_i_click_on_the_course_age_range_link
    reference_data_page.course_age_range_link.click
  end

  def and_i_see_the_course_age_range_data
    expect(reference_data_page).to have_course_age_range_heading
  end

  def and_i_click_on_the_download_entries_link
    reference_data_page.course_age_range_download_link.click
  end

  def then_i_receive_the_data_entries_as_a_file
    expect(download_filename).to eq("course-age-range-v2025.0-rc.csv")
    expect(parsed_download_content).to eq(parsed_course_age_range_file)
  end

  def parsed_download_content
    CSV.parse(download_content, headers: true).map(&:to_h)
  end

  def parsed_course_age_range_file
    CSV.parse(file_content("reference_data/v2025_0_rc/course_age_range.csv"), headers: true).map(&:to_h)
  end
end

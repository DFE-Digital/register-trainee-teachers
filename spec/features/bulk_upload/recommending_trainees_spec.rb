# frozen_string_literal: true

require "rails_helper"

feature "recommending trainees" do
  background do
    given_i_am_authenticated
  end

  scenario "uploading trainees for recommendation" do
    given_i_am_on_the_recommendation_upload_page
    and_i_upload_a_csv
    and_i_check_who_ill_recommend
  end

private

  def given_i_am_on_the_recommendation_upload_page
    recommendation_upload_page.load
  end

  def and_i_upload_a_csv
    recommendation_upload_page.upload_button.click
  end

  def and_i_check_who_ill_recommend
    recommendation_upload_show_page.check_button.click
  end
end

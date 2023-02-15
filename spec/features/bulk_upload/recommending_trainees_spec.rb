# frozen_string_literal: true

require "rails_helper"

feature "recommending trainees" do
  background do
    given_i_am_authenticated
  end

  scenario "uploading trainees for recommendation" do
    given_i_am_on_the_recommendation_upload_page
  end

private

  def given_i_am_on_the_recommendation_upload_page
    recommendation_upload_page.load
  end
end

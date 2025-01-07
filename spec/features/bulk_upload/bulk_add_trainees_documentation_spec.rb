# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees documentation" do
  context "when the feature flag is off", feature_bulk_add_trainees: false do
    scenario "the documentation page is not-visible when feature flag is off" do
      when_i_visit_the_csv_docs_page
      then_i_am_redirected_to_the_home_page
    end
  end

  context "when the feature flag is on", feature_bulk_add_trainees: true do
    scenario "the documentation page is visible when feature flag is off" do
      when_i_visit_the_csv_docs_page
      then_i_see_the_csv_docs
    end
  end
end

def when_i_visit_the_csv_docs_page
  visit "/csv-docs"
end

def then_i_see_the_csv_docs
  expect(page).to have_content(
    "How to add trainee information to the bulk add new trainee CSV template",
  )
end

def then_i_am_redirected_to_the_home_page
  expect(page).not_to have_content(
    "How to add trainee information to the bulk add new trainee CSV template",
  )
end

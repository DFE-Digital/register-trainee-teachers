# frozen_string_literal: true

require "rails_helper"

feature "bulk add trainees documentation" do
  scenario "the documentation page is visible when feature flag is off" do
    when_i_visit_the_csv_docs_page
    then_i_see_the_csv_docs
  end
end

def when_i_visit_the_csv_docs_page
  visit "/csv-docs/"
end

def then_i_see_the_csv_docs
  expect(page).to have_content(
    "How to add trainee information to the bulk add new trainee CSV template",
  )
end

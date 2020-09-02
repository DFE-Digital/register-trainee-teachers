require "rails_helper"

RSpec.feature "Create trainee journey" do
  scenario "see summary page afterwards" do
    visit "/trainees/new"

    fill_in "Trainee ID", with: "123"
    click_on "Continue"

    expect(page.current_path).to match(/\/trainees\/\d+/)
    expect(page).to have_content("123")
  end
end

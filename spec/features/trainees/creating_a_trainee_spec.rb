require "rails_helper"

RSpec.feature "Trainee creation journey", type: :system do
  let(:trainee_create_page) { PageObjects::Trainees::CreatePage.new }
  let(:trainee_id) { 123 }

  before do
    trainee_create_page.load
  end

  scenario "creating the trainee" do
    trainee_create_page.trainee_id_field.set(trainee_id)
    trainee_create_page.continue.click

    expect(page.current_path).to match(/\/trainees\/\d+/)
    expect(page).to have_content("123")
  end
end

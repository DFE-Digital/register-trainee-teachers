require "rails_helper"

RSpec.feature "Trainee summary page", type: :system do
  let(:summary_page) { PageObjects::Trainees::SummaryPage.new }
  let(:trainee) { create(:trainee) }

  before do
    summary_page.load(id: trainee.id)
  end

  scenario "displays the personal details" do
    expect(summary_page.personal_details.trainee_id.text).to eq(trainee.trainee_id)
  end
end

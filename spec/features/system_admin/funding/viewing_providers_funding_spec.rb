# frozen_string_literal: true

require "rails_helper"

feature "Viewing provider's funding" do
  let(:user) { create(:user, system_admin: true) }
  let(:provider) { create(:provider) }

  before do
    given_i_am_authenticated(user: user)
    and_funding_data_exists
    when_i_visit_the_provider_show_page
    when_i_click_view_funding
  end

  scenario "shows the admin the payment schedules" do
    then_i_see_the_payment_schedule
  end

  scenario "shows the admin the trainee summary" do
    when_i_click_trainee_summary
    then_i_see_the_trainee_summary
  end

  def and_funding_data_exists
    create(:academic_cycle, :current)
    create(:payment_schedule, payable: provider)
    create(:trainee_summary, :with_bursary_and_scholarship_rows, payable: provider)
  end

  def when_i_visit_the_provider_show_page
    provider_show_page.load(id: provider.id)
  end

  def when_i_click_view_funding
    provider_show_page.view_funding.click
  end

  def then_i_see_the_payment_schedule
    expect(providers_payment_schedule_page.payment_breakdown_tables.size).to eq(1)
  end

  def when_i_click_trainee_summary
    providers_payment_schedule_page.view_trainee_summary.click
  end

  def then_i_see_the_trainee_summary
    expect(providers_trainee_summary_page).to have_text("ITT bursaries")
  end
end

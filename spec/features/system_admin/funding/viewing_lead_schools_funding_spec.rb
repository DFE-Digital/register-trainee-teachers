# frozen_string_literal: true

require "rails_helper"

feature "Viewing lead school's funding" do
  let(:user) { create(:user, system_admin: true) }
  let(:lead_school) { create(:school, lead_school: true) }

  before do
    given_i_am_authenticated(user: user)
    and_funding_data_exists
    when_i_visit_the_lead_school_show_page
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
    create(:payment_schedule, payable: lead_school)
    create(:trainee_summary, :with_grant_rows, payable: lead_school)
  end

  def when_i_visit_the_lead_school_show_page
    lead_school_show_page.load(id: lead_school.id)
  end

  def when_i_click_view_funding
    lead_school_show_page.view_funding.click
  end

  def then_i_see_the_payment_schedule
    expect(lead_schools_payment_schedule_page.payment_breakdown_tables.size).to eq(1)
  end

  def when_i_click_trainee_summary
    lead_schools_payment_schedule_page.view_trainee_summary.click
  end

  def then_i_see_the_trainee_summary
    expect(lead_schools_trainee_summary_page).to have_text("Grants breakdown")
  end
end

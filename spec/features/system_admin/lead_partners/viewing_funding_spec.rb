# frozen_string_literal: true

require "rails_helper"

feature "Viewing lead partner's funding", :feature_lead_partners do
  let(:user) { create(:user, system_admin: true) }
  let(:lead_partner) { create(:lead_partner, :lead_school) }
  let(:current_cycle) { AcademicCycle.current }

  scenario "view funding and payment schedule" do
    given_i_am_authenticated(user:)
    and_funding_data_exists
    when_i_visit_the_lead_partner_show_page
    when_i_click_view_funding
    then_i_see_the_payment_schedule

    when_i_click_trainee_summary
    then_i_see_the_trainee_summary

    when_i_click_payment_schedule_again
    then_i_see_the_payment_schedule

    when_i_click_back
    then_i_see_the_lead_partner_show_page
  end

  def and_funding_data_exists
    create(:payment_schedule, payable: lead_partner)
    create(:trainee_summary, :with_grant_rows, payable: lead_partner)
  end

  def when_i_visit_the_lead_partner_show_page
    visit lead_partner_path(lead_partner)
  end

  def when_i_click_view_funding
    click_on("View funding")
    click_on("#{current_cycle.start_year} to #{current_cycle.end_year}")
  end

  def then_i_see_the_payment_schedule
    expect(page.find_all(".app-table__in-accordion tbody tr").count).to eq(2)
  end

  def when_i_click_trainee_summary
    click_on("Trainee summary #{current_cycle.start_year} to #{current_cycle.end_year}")
  end

  def then_i_see_the_trainee_summary
    expect(page).to have_css("h2", text: "Trainee summary #{current_cycle.start_year} to #{current_cycle.end_year}")
    expect(page.find_all(".govuk-grid-column-one-half-from-desktop tbody tr").count).to eq(2)
    expect(page.find_all(".govuk-grid-column-two-thirds-from-desktop tbody tr").count).to eq(2)
  end

  def when_i_click_payment_schedule_again
    click_on("Payment schedule #{current_cycle.start_year} to #{current_cycle.end_year}")
  end

  def when_i_click_back
    click_on("All funding years")
    click_on("Back")
  end

  def then_i_see_the_lead_partner_show_page
    save_and_open_page
  end
end

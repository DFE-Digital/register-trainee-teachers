# frozen_string_literal: true

require "rails_helper"

feature "Viewing provider's funding" do
  let(:user) { create(:user, system_admin: true) }
  let(:provider) { create(:provider) }
  let(:next_academic_cycle) { build(:academic_cycle, start_date: Time.zone.yesterday + 1.year, end_date: Time.zone.tomorrow + 1.year) }

  before do
    given_i_am_authenticated(user:)
    and_funding_data_exists_for_current_academic_year
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

  scenario "shows the admin a message when there are no payments this academic year" do
    allow(AcademicCycle).to receive(:current).and_return(next_academic_cycle)

    when_i_visit_the_providers_payment_schedule_page
    then_i_see_a_message_to_say_there_are_no_payments
  end

  def and_funding_data_exists_for_current_academic_year
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

  def when_i_visit_the_providers_payment_schedule_page
    providers_payment_schedule_page.load(id: provider.id)
  end

  def then_i_see_a_message_to_say_there_are_no_payments
    expect(providers_payment_schedule_page).to have_text("There are no scheduled payments right now.")
    expect(providers_payment_schedule_page).to have_text(
      "Contact ITT.FUNDING@education.gov.uk if you think there should be scheduled payments.",
    )
    expect(providers_payment_schedule_page).to have_link("ITT.FUNDING@education.gov.uk")
  end

  def when_i_click_trainee_summary
    providers_payment_schedule_page.view_trainee_summary.click
  end

  def then_i_see_the_trainee_summary
    expect(providers_trainee_summary_page).to have_text("ITT bursaries")
  end
end

# frozen_string_literal: true

require "rails_helper"

feature "viewing funding list", feature_funding: true do
  let(:user) { create(:user) }
  let(:test_subject) { "Test subject" }
  let(:summary) { create(:trainee_summary, payable: user.providers.first) }
  let(:row) { create(:trainee_summary_row, trainee_summary: summary, subject: test_subject) }

  let!(:trainee_summary_row_amount) { create(:trainee_summary_row_amount, :with_bursary, row:) }
  let!(:payment_schedule) do
    create(:payment_schedule, rows: [
      build(:payment_schedule_row, amounts: [
        build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
        build(:payment_schedule_row_amount, month: 3, amount_in_pence: 600, predicted: true),
      ]),
    ], payable: user.providers.first)
  end

  background do
    given_i_am_authenticated(user:)
  end

  context "with payment schedule and trainee summary sharing the same academic year" do
    scenario "shows only one link for payment schedule" do
      given_i_am_on_the_funding_show_page
      i_see_only_one_funding_link
    end
  end

  context "with payment schedule and trainee summary with differing academic years" do
    scenario "shows a link for trainee summary and a link for payment schedule" do
      and_funding_data_exists_in_different_academic_years
      given_i_am_on_the_funding_show_page
      i_see_two_funding_links
    end
  end

private

  def and_funding_data_exists_in_different_academic_years
    payment_schedule.rows.first.amounts.first.update(year: 2022)
  end

  def given_i_am_on_the_funding_show_page
    funding_page.load
  end

  def i_see_only_one_funding_link
    expect(funding_page.funding_list.items.length).to be 1
    expect(funding_page.funding_list.items.first).to have_text(AcademicCycle.current.label)
  end

  def i_see_two_funding_links
    expect(funding_page.funding_list.items.length).to be 2
    expect(funding_page.funding_list.items.first).to have_text(AcademicCycle.current.label)
    expect(funding_page.funding_list.items[1]).to have_text("2022 to 2023")
  end
end

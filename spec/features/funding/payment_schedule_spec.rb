# frozen_string_literal: true

require "rails_helper"

feature "viewing the payment schedule" do
  background do
    given_i_am_authenticated
    and_funding_data_exists
  end

  scenario "viewing payments, predicted payments and payment breakdowns" do
    given_i_am_on_the_funding_page
    then_i_should_see_the_actual_payments
    and_i_should_see_the_predicted_payments
    and_i_should_see_the_payment_breakdowns
  end

  scenario "exporting payment schedule" do
    given_i_am_on_the_funding_page
    and_i_export_the_results
    then_i_see_my_exported_data_in_csv_format
  end

private

  def and_funding_data_exists
    create(:payment_schedule, rows: [
      build(:payment_schedule_row, amounts: [
        build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
        build(:payment_schedule_row_amount, month: 2, amount_in_pence: 200),
        build(:payment_schedule_row_amount, month: 3, amount_in_pence: 600, predicted: true),
      ]),
    ], payable: current_user.providers.first)
  end

  def given_i_am_on_the_funding_page
    payment_schedule_page.load
  end

  def then_i_should_see_the_actual_payments
    expect(payment_schedule_page.payments_table.rows.size).to eq(3) # 1 row is the header
  end

  def and_i_should_see_the_predicted_payments
    expect(payment_schedule_page.predicted_payments_table.rows.size).to eq(2) # 1 row is the header
  end

  def and_i_should_see_the_payment_breakdowns
    expect(payment_schedule_page.payment_breakdown_tables.size).to eq(3)
  end

  def and_i_export_the_results
    payment_schedule_page.export_link.click
  end

  def then_i_see_my_exported_data_in_csv_format
    expect(csv_data).to include("Month,#{Funding::PaymentScheduleRow.first.description},Month total")
    expect(csv_data).to include("March 2022,£6.00,£6.00")
    expect(csv_data).to include("Total,£9.00,£9.00")
  end

  def csv_data
    @csv_data ||= payment_schedule_page.text
  end
end

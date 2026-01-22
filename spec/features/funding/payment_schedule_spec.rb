# frozen_string_literal: true

require "rails_helper"

feature "viewing the payment schedule" do
  let(:next_academic_cycle) { build(:academic_cycle, start_date: Time.zone.yesterday + 1.year, end_date: Time.zone.tomorrow + 1.year) }

  context "when User is a Provider" do
    background do
      given_i_am_authenticated

      and_funding_data_exists(current_user.providers.first)
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

    scenario "no payments this academic year" do
      allow(AcademicCycle).to receive(:current).and_return(next_academic_cycle)

      given_i_am_on_the_funding_page
      then_i_should_see_a_message_to_say_there_are_no_payments
    end
  end

  context "when User is a TrainingPartner School" do
    let(:user) { create(:user, :with_training_partner_organisation, training_partner_type: :school) }

    background do
      given_i_am_authenticated_as_a_training_partner_user(user:)

      and_funding_data_exists(current_user.training_partners.first.school)
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

    scenario "no payments this academic year" do
      allow(AcademicCycle).to receive(:current).and_return(next_academic_cycle)

      given_i_am_on_the_funding_page
      then_i_should_see_a_message_to_say_there_are_no_payments
    end
  end

  context "when User is a TrainingPartner provider" do
    let(:user) { create(:user, :with_training_partner_organisation, training_partner_type: :hei) }

    background do
      given_i_am_authenticated_as_a_training_partner_user(user:)

      and_funding_data_exists(current_user.training_partners.first.provider)
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

    scenario "no payments this academic year" do
      allow(AcademicCycle).to receive(:current).and_return(next_academic_cycle)

      given_i_am_on_the_funding_page
      then_i_should_see_a_message_to_say_there_are_no_payments
    end
  end

private

  def and_funding_data_exists(payable)
    create(:payment_schedule, rows: [
      build(:payment_schedule_row, amounts: [
        build(:payment_schedule_row_amount, month: 1, amount_in_pence: 100),
        build(:payment_schedule_row_amount, month: 2, amount_in_pence: 200),
        build(:payment_schedule_row_amount, month: 3, amount_in_pence: 600, predicted: true),
      ]),
    ], payable: payable)
  end

  def given_i_am_on_the_funding_page
    payment_schedule_page.load
  end

  def then_i_should_see_the_actual_payments
    expect(payment_schedule_page.payments_table.rows.size).to eq(3) # 1 row is the header
  end

  def then_i_should_see_a_message_to_say_there_are_no_payments
    expect(payment_schedule_page).to have_text("There are no scheduled payments right now.")
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
    expect(csv_data).to include("March #{current_academic_year + 1},£6.00,£6.00")
    expect(csv_data).to include("Total,£9.00,£9.00")
  end

  def csv_data
    @csv_data ||= payment_schedule_page.text
  end
end

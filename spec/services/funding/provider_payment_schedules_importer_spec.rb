# frozen_string_literal: true

require "rails_helper"

module Funding
  describe ProviderPaymentSchedulesImporter do
    context "valid attributes" do
      let(:schedules_attributes) do
        {
          "5635" => [
            {
              "Academic year" => "2021/22",
              "Provider ID" => "5635",
              "Provider name" => "Provider 1",
              "Description" => "Training bursary trainees",
              "Total funding" => "1676000.00",
              "August" => nil,
              "September" => "88587.00",
              "October" => "88587.00",
              "November" => "88587.00",
              "December" => "338319.00",
              "January" => "151020.00",
              "February" => "151020.00",
              "March" => "216800.00",
              "April" => "150840.00",
              "May" => "150840.00",
              "June" => "150840.00",
              "July" => "100560.00",
            },
            {
              "Academic year" => "2021/22",
              "Provider ID" => "5635",
              "Provider name" => "Provider 1",
              "Description" => "Course extension provider payments for AY 20/21",
              "Total funding" => "4000",
              "August" => nil,
              "September" => "1000",
              "October" => "1000",
              "November" => "1200",
              "December" => "1000",
              "January" => "0",
              "February" => "0",
              "March" => "0",
              "April" => "0",
              "May" => "0",
              "June" => "0",
              "July" => "0",
            },
          ],
          "5636" => [
            {
              "Academic year" => "2021/22",
              "Provider ID" => "5636",
              "Provider name" => "Provider 1",
              "Description" => "Course extension trainee payments for AY 20/21",
              "Total funding" => "13,000.00",
              "August" => "3250",
              "September" => "3,250.00",
              "October" => "3,250.00",
              "November" => "1,625.00",
              "December" => "",
              "January" => "0",
              "February" => "0",
              "March" => "0",
              "April" => "0",
              "May" => "0",
              "June" => "0",
              "July" => "0",
            },
          ],
        }
      end
      let(:provider_one) { create(:provider, accreditation_id: 5635) }
      let(:provider_two) { create(:provider, accreditation_id: 5636) }
      let(:provider_ids) { [provider_one.id, provider_two.id] }
      let(:expected_provider_one_row_descriptions) do
        [
          "Training bursary trainees",
          "Course extension provider payments for AY 20/21",
        ]
      end
      let(:expected_provider_two_row_descriptions) do
        [
          "Course extension trainee payments for AY 20/21",
        ]
      end
      let(:provider_two_row) { provider_two.funding_payment_schedules.last.rows.last }
      let(:provider_one_second_row) { provider_one.funding_payment_schedules.last.rows.second }
      let(:provider_one_first_row) { provider_one.funding_payment_schedules.last.rows.first }

      subject { described_class.call(attributes: schedules_attributes, first_predicted_month_index: 12) }

      before do
        provider_ids
      end

      it "creates a Funding::PaymentSchedule for each provider" do
        expect { subject }.to change { Funding::PaymentSchedule.where(payable_id: provider_ids, payable_type: "Provider").count }.by(2)
      end

      it "creates a PaymentScheduleRow for each entry" do
        subject
        expect(provider_one.funding_payment_schedules.last.rows.map(&:description)).to match_array(expected_provider_one_row_descriptions)
        expect(provider_two.funding_payment_schedules.last.rows.map(&:description)).to match_array(expected_provider_two_row_descriptions)
      end

      it "creates the monthly ammounts for each row" do
        subject
        expect(provider_one_first_row.amounts.count).to eq(12)
        expect(provider_one_second_row.amounts.count).to eq(12)
        expect(provider_two_row.amounts.count).to eq(12)
      end

      it "sets the amount correctly" do
        subject
        august_amount = provider_two_row.amounts.find_by(month: 8)
        expect(august_amount.amount_in_pence).to eq(325000)
      end

      it "sets the amount correctly for amounts containing commas" do
        subject
        november_amount = provider_two_row.amounts.find_by(month: 11)
        expect(november_amount.amount_in_pence).to eq(162500)
      end

      it "sets the amount to 0 when the value is blank" do
        subject
        december_amount = provider_two_row.amounts.find_by(month: 12)
        expect(december_amount.amount_in_pence).to eq(0)
      end

      it "sets the year correctly" do
        subject
        months2022 = [1, 2, 3, 4, 5, 6, 7]
        months2021 = [8, 9, 10, 11, 12]

        months2022.each do |month_index|
          year = provider_two_row.amounts.find_by(month: month_index).year
          expect(year).to eq(2022)
        end

        months2021.each do |month_index|
          year = provider_two_row.amounts.find_by(month: month_index).year
          expect(year).to eq(2021)
        end
      end

      context "predicted month is passed" do
        it "sets predicted correctly" do
          subject
          expect(provider_one_first_row.amounts.find_by(month: 11)).not_to be_predicted
          expect(provider_one_first_row.amounts.find_by(month: 12)).not_to be_predicted
          expect(provider_one_first_row.amounts.find_by(month: 1)).to be_predicted
        end
      end

      context "predicted month is nil" do
        subject { described_class.call(attributes: schedules_attributes, first_predicted_month_index: nil) }

        it "sets all months as actual" do
          subject
          expect(provider_one_first_row.amounts.where(predicted: false).count).to eq(12)
        end
      end
    end

    context "unknown provider" do
      let(:invalid_schedules_attributes) do
        {
          "5635" => [
            {
              "Academic year" => "2021/22",
              "Provider ID" => "5635",
              "Provider name" => "Provider 1",
              "Description" => "Training bursary trainees",
              "Total funding" => "1676000.00",
              "August" => nil,
              "September" => "88587.00",
              "October" => "88587.00",
              "November" => "88587.00",
              "December" => "338319.00",
              "January" => "151020.00",
              "February" => "151020.00",
              "March" => "216800.00",
              "April" => "150840.00",
              "May" => "150840.00",
              "June" => "150840.00",
              "July" => "100560.00",
            },
          ],
        }
      end

      subject { described_class.call(attributes: invalid_schedules_attributes, first_predicted_month_index: 12) }

      it "returns a list of provider accreditation ids not found in database" do
        expect(subject).to eq(["5635"])
      end
    end
  end
end

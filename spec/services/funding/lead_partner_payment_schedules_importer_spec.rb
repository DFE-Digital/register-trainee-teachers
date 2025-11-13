# frozen_string_literal: true

require "rails_helper"

module Funding
  describe LeadPartnerPaymentSchedulesImporter do
    context "valid attributes" do
      let(:schedules_attributes) do
        {
          "105491" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "105491",
              "Lead school name" => "School 3",
              "Description" => "Course extension trainee funding",
              "Total funding" => "6500",
              "August" => "1625.00",
              "September" => "1625.00",
              "October" => "1625.00",
              "November" => "812.50",
              "December" => "812.50",
              "January" => "0.00",
              "February" => "0.00",
              "March" => "0.00",
              "April" => "0.00",
              "May" => "0.00",
              "June" => "0.00",
              "July" => "0.00",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "105491",
              "Lead school name" => "School 3",
              "Description" => "Course extension provider funding",
              "Total funding" => "2000",
              "August" => "0.00",
              "September" => "500.00",
              "October" => "500.00",
              "November" => "500.00",
              "December" => "500.00",
              "January" => "0.00",
              "February" => "0.00",
              "March" => "0.00",
              "April" => "0.00",
              "May" => "0.00",
              "June" => "0.00",
              "July" => "0.00",
            },
          ],
          "103527" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "103527",
              "Lead school name" => "School 4",
              "Description" => "School Direct (salaried)",
              "Total funding" => "0",
              "August" => "0.00",
              "September" => "4320.00",
              "October" => "4320.00",
              "November" => "4320.00",
              "December" => "0.00",
              "January" => "0.00",
              "February" => "0.00",
              "March" => "0.00",
              "April" => "0.00",
              "May" => "0.00",
              "June" => "0.00",
              "July" => "0.00",
            },
          ],
          "131238" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "131238",
              "Lead school name" => "School 1",
              "Description" => "FE ITT Bursary for AY 2021/22",
              "Total funding" => "90000",
              "August" => nil,
              "September" => "3420.00",
              "October" => "12874.50",
              "November" => "8194.50",
              "December" => "8194.50",
              "January" => "8194.50",
              "February" => "8194.50",
              "March" => "8194.50",
              "April" => "8183.25",
              "May" => "8183.25",
              "June" => "8183.25",
              "July" => "8183.25",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "131238",
              "Lead school name" => "School 1",
              "Description" => "FE ITT in-year adjs for AY 2021/22",
              "Total funding" => "-26000",
              "August" => nil,
              "September" => nil,
              "October" => nil,
              "November" => "-5200.00",
              "December" => "2600.00",
              "January" => "2600.00",
              "February" => "2600.00",
              "March" => "2600.00",
              "April" => "2600.00",
              "May" => "2600.00",
              "June" => "2600.00",
              "July" => "2600.00",
            },
          ],
          "135438" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "135438",
              "Lead school name" => "School 2",
              "Description" => "FE ITT Grant for AY 2021/22",
              "Total funding" => "91000",
              "August" => nil,
              "September" => nil,
              "October" => "16480.10",
              "November" => "8,285.55",
              "December" => "",
              "January" => "8285.55",
              "February" => "8285.55",
              "March" => "8285.55",
              "April" => "8274.17",
              "May" => "8274.18",
              "June" => "8271.90",
              "July" => "8271.90",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "135438",
              "Lead school name" => "School 2",
              "Description" => "FE ITT in-year adjs for AY 2021/22",
              "Total funding" => "-18200",
              "August" => nil,
              "September" => nil,
              "October" => nil,
              "November" => "-3640.00",
              "December" => "-1820.00",
              "January" => "-1820.00",
              "February" => "-1820.00",
              "March" => "-1820.00",
              "April" => "-1820.00",
              "May" => "-1820.00",
              "June" => "-1820.00",
              "July" => "-1820.00",
            },
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "135438",
              "Lead school name" => "School 2",
              "Description" => "FE AGR Adjustments AY20/21",
              "Total funding" => "-11696.31",
              "August" => nil,
              "September" => nil,
              "October" => nil,
              "November" => nil,
              "December" => nil,
              "January" => nil,
              "February" => nil,
              "March" => nil,
              "April" => nil,
              "May" => "-3976.75",
              "June" => "-3859.78",
              "July" => "-3859.78",
            },
          ],
        }
      end

      let(:school_one) { create(:school, urn: "131238") }
      let(:school_two) { create(:school, urn: "135438") }
      let(:school_three) { create(:school, urn: "103527") }
      let(:school_four) { create(:school, urn: "105491") }
      let(:school_ids) { [school_one.id, school_two.id, school_three.id, school_four.id] }
      let(:school_one_second_row) { school_one.funding_payment_schedules.last.rows.second }
      let(:school_one_first_row) { school_one.funding_payment_schedules.last.rows.first }
      let(:school_two_first_row) { school_two.funding_payment_schedules.last.rows.first }

      let(:expected_school_one_row_descriptions) do
        [
          "FE ITT Bursary for AY 2021/22",
          "FE ITT in-year adjs for AY 2021/22",
        ]
      end

      let(:expected_school_two_first_row_descriptions) do
        [
          "FE ITT Grant for AY 2021/22",
          "FE ITT in-year adjs for AY 2021/22",
          "FE AGR Adjustments AY20/21",
        ]
      end

      subject { described_class.call(attributes: schedules_attributes, first_predicted_month_index: 12) }

      before do
        school_ids
      end

      it "creates a Funding::PaymentSchedule for each school" do
        expect { subject }.to change { Funding::PaymentSchedule.where(payable_id: school_ids, payable_type: "School").count }.by(4)
      end

      it "creates a PaymentScheduleRow for each entry" do
        subject
        expect(school_one.funding_payment_schedules.last.rows.map(&:description)).to match_array(expected_school_one_row_descriptions)
        expect(school_two.funding_payment_schedules.last.rows.map(&:description)).to match_array(expected_school_two_first_row_descriptions)
      end

      it "creates the monthly amounts for each row" do
        subject
        expect(school_one_first_row.amounts.count).to eq(12)
        expect(school_one_second_row.amounts.count).to eq(12)
        expect(school_two_first_row.amounts.count).to eq(12)
      end

      it "sets the amount correctly" do
        subject
        october_amount = school_two_first_row.amounts.find_by(month: 10)
        expect(october_amount.amount_in_pence).to eq(1648010)
      end

      it "sets the amount correctly for amounts containing commas" do
        subject
        november_amount = school_two_first_row.amounts.find_by(month: 11)
        expect(november_amount.amount_in_pence).to eq(828555)
      end

      it "sets the amount to 0 when the value is blank" do
        subject
        december_amount = school_two_first_row.amounts.find_by(month: 12)
        expect(december_amount.amount_in_pence).to eq(0)
      end

      it "sets the year correctly" do
        subject
        months2022 = [1, 2, 3, 4, 5, 6, 7]
        months2021 = [8, 9, 10, 11, 12]

        months2022.each do |month_index|
          year = school_two_first_row.amounts.find_by(month: month_index).year
          expect(year).to eq(2022)
        end

        months2021.each do |month_index|
          year = school_two_first_row.amounts.find_by(month: month_index).year
          expect(year).to eq(2021)
        end
      end

      context "first predicted month is passed" do
        it "sets predicted correctly" do
          subject
          expect(school_one_first_row.amounts.find_by(month: 11)).not_to be_predicted
          expect(school_one_first_row.amounts.find_by(month: 12)).not_to be_predicted
          expect(school_one_first_row.amounts.find_by(month: 1)).to be_predicted
        end
      end

      context "first predicted month is nil" do
        subject { described_class.call(attributes: schedules_attributes, first_predicted_month_index: nil) }

        it "sets all months predicted to false" do
          subject
          expect(school_one_first_row.amounts.where(predicted: false).count).to eq(12)
        end
      end
    end

    context "unknown school" do
      let(:invalid_schedules_attributes) do
        {
          "105491" => [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "105491",
              "Lead school name" => "School 3",
              "Description" => "Course extension trainee funding",
              "Total funding" => "6500",
              "August" => "1625.00",
              "September" => "1625.00",
              "October" => "1625.00",
              "November" => "812.50",
              "December" => "812.50",
              "January" => "0.00",
              "February" => "0.00",
              "March" => "0.00",
              "April" => "0.00",
              "May" => "0.00",
              "June" => "0.00",
              "July" => "0.00",
            },
          ],
        }
      end

      subject { described_class.call(attributes: invalid_schedules_attributes, first_predicted_month_index: 12) }

      it "returns a list of school urns not found in database" do
        expect(subject).to eq(["105491"])
      end
    end
  end
end

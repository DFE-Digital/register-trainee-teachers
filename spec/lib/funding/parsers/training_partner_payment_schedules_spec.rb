# frozen_string_literal: true

require "rails_helper"

module Funding
  module Parsers
    describe TrainingPartnerPaymentSchedules do
      context "valid csv" do
        let(:funding_upload) { create(:funding_upload, :lead_partner_payment_schedules) }
        let(:expected_urns) { %w[103527 105491 131238 135438] }
        let(:expected_school_131948_result) do
          [
            {
              "Academic year" => "2021/22",
              "Lead school URN" => "135438",
              "Lead school name" => "Lead School 2",
              "Description" => "FE ITT Grant for AY 2021/22",
              "Total funding" => "91000",
              "August" => nil,
              "September" => nil,
              "October" => "16480.10",
              "November" => "8285.55",
              "December" => "8285.55",
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
              "Lead school name" => "Lead School 2",
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
              "Lead school name" => "Lead School 2",
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
          ]
        end

        subject { described_class.to_attributes(funding_upload:) }

        it "returns an hash with key for each school" do
          keys = subject.keys
          expect(keys).to match_array(expected_urns)
        end

        it "returns a hash with an array of matching row hashes for each provider" do
          expect(subject["135438"]).to eq(expected_school_131948_result)
        end
      end

      context "invalid csv" do
        let(:funding_upload) { create(:funding_upload, :invalid_lead_partner_payment_schedules) }

        subject { described_class.to_attributes(funding_upload:) }

        it "is expected to raise error" do
          expect { subject }.to raise_error(NameError, "Column headings: Augustus not recognised")
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Funding
  module Parsers
    describe ProviderPaymentSchedules do
      subject { described_class.to_attributes(file_path: Rails.root.join("spec/support/fixtures/provider_payment_schedules.csv")) }

      let(:expected_accreditation_ids) { %w(5635 5610 5660 5697) }

      it "returns an hash with key for each provider" do
        keys = subject.keys
        expect(keys).to match_array(expected_accreditation_ids)
      end

      let(:expected_provider_5635_result) do
        [
          {
            "Academic year"=>"2021/22",
            "Provider ID"=>"5635",
            "Provider name"=>"Provider 1",
            "Description"=>"Training bursary trainees",
            "Total funding"=>"1676000.00",
            "August"=>nil,
            "September"=>"88587.00",
            "October"=>"88587.00",
            "November"=>"88587.00",
            "December"=>"338319.00",
            "January"=>"151020.00",
            "February"=>"151020.00",
            "March"=>"216800.00",
            "April"=>"150840.00",
            "May"=>"150840.00",
            "June"=>"150840.00",
            "July"=>"100560.00"
          },
          {
            "Academic year"=>"2021/22",
            "Provider ID"=>"5635",
            "Provider name"=>"Provider 1",
            "Description"=>"Course extension provider payments for AY 20/21",
            "Total funding"=>"4000",
            "August"=>nil,
            "September"=>"1000",
            "October"=>"1000",
            "November"=>"1000",
            "December"=>"1000",
            "January"=>"0",
            "February"=>"0",
            "March"=>"0",
            "April"=>"0",
            "May"=>"0",
            "June"=>"0",
            "July"=>"0"
          },
          {
            "Academic year"=>"2021/22",
            "Provider ID"=>"5635",
            "Provider name"=>"Provider 1",
            "Description"=>"Course extension trainee payments for AY 20/21",
            "Total funding"=>"13,000.00",
            "August"=>"3250",
            "September"=>"3,250.00",
            "October"=>"3,250.00",
            "November"=>"1,625.00",
            "December"=>"1,625.00",
            "January"=>"0",
            "February"=>"0",
            "March"=>"0",
            "April"=>"0",
            "May"=>"0",
            "June"=>"0",
            "July"=>"0"
          },
          {
            "Academic year"=>"2021/22",
            "Provider ID"=>"5635",
            "Provider name"=>"Provider 1",
            "Description"=>"TB 21/22 in-year adjustment for withdrawals",
            "Total funding"=>"-102600",
            "August"=>nil, "September"=>nil,
            "October"=>nil, "November"=>nil,
            "December"=>"-41700",
            "January"=> "-41700",
            "February"=>"0",
            "March"=>"-19200",
            "April"=>"0",
            "May"=>"0",
            "June"=>"0",
            "July"=>"0"
          },
        ]
      end

      it "returns a hash with an array of matching row hashes for each provider" do
        expect(subject["5635"]).to eq(expected_provider_5635_result)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250::EnhancedErrorsSerializer do
  subject { described_class.new(errors) }

  context "with non excluded attributes" do
    let(:errors) do
      [
        "itt_start_date is invalid",
        "trainee_start_date is invalid",
        "graduation_year must be in the past, for example 2014",
        "graduation_year is invalid",
      ]
    end

    it "returns enhanced errors" do
      expect(subject.as_hash).to eq(
        "graduation_year" => [
          "must be in the past, for example 2014",
          "is invalid",
        ],
        "itt_start_date" => ["is invalid"],
        "trainee_start_date" => ["is invalid"]
      )
    end
  end

  %w[
      personal_details
      contact_details
      diversity
      course_details
      training_details
      trainee_start_status
      trainee_data schools
      funding
      iqts_country
  ].each do |attribute|
    context "with excluded attribute #{attribute}" do
      let(:errors) do
        {
            attribute => {
              "nested_attribute" => ["error occured"]
            }
        }
      end

      it "returns the errors" do
        expect(subject.as_hash).to eq(errors)
      end
    end
  end
end

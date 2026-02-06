# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hesa::ReferenceData::V20260 do
  include FileHelper

  describe "as_csv" do
    it "converts data to csv" do
      expect(
        CSV.parse(described_class.find(:course_age_range).as_csv),
      ).to eq(
        CSV.parse(file_content("reference_data/v2026_0/course_age_range.csv")),
      )
    end
  end
end

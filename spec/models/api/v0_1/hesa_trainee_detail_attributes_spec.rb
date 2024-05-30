# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::HesaTraineeDetailAttributes do
  subject { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:itt_aim) }
    it { is_expected.to validate_presence_of(:itt_qualification_aim) }
    it { is_expected.to validate_presence_of(:course_year) }
    it { is_expected.to validate_presence_of(:course_age_range) }
    it { is_expected.to validate_presence_of(:fund_code) }
    it { is_expected.to validate_presence_of(:funding_method) }
    it { is_expected.to validate_inclusion_of(:course_age_range).in_array(Hesa::CodeSets::AgeRanges::MAPPING.keys) }
  end
end

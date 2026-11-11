# frozen_string_literal: true

require "rails_helper"

describe FundingSchoolDesignation do
  subject { create(:funding_school_designation) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:designation) }
    it { is_expected.to validate_uniqueness_of(:school_id).scoped_to(:academic_cycle_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:academic_cycle) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:designation).with_values(disadvantaged: "disadvantaged", special: "special").backed_by_column_of_type(:string) }
  end
end

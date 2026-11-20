# frozen_string_literal: true

require "rails_helper"

describe FundingMethod do
  subject { create(:funding_method) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:training_route) }
    it { is_expected.to validate_inclusion_of(:training_route).in_array(TRAINING_ROUTE_ENUMS.values) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:academic_cycle) }
    it { is_expected.to have_many(:funding_method_subjects) }
    it { is_expected.to have_many(:allocation_subjects).through(:funding_method_subjects) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:degree_relevance).with_values(relevant: "relevant", unrelated: "unrelated").with_prefix(:degree).backed_by_column_of_type(:string) }
    it { is_expected.to define_enum_for(:school_disadvantage).with_values(disadvantaged: "disadvantaged", non_disadvantaged: "non_disadvantaged").with_prefix(:school).backed_by_column_of_type(:string) }
  end
end

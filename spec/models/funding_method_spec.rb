# frozen_string_literal: true

require "rails_helper"

describe FundingMethod do
  subject { create(:funding_method) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:training_route) }
    it { is_expected.to validate_inclusion_of(:training_route).in_array(ReferenceData::TRAINING_ROUTES.names) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:academic_cycle) }
    it { is_expected.to have_many(:funding_method_subjects) }
    it { is_expected.to have_many(:allocation_subjects).through(:funding_method_subjects) }
  end
end

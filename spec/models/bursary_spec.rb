# frozen_string_literal: true

require "rails_helper"

describe Bursary do
  subject { create(:bursary) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:training_route) }
    it { is_expected.to validate_inclusion_of(:training_route).in_array(TRAINING_ROUTE_ENUMS.values) }
    it { is_expected.to validate_presence_of(:amount) }
  end

  describe "associations" do
    it { is_expected.to have_many(:bursary_subjects) }
    it { is_expected.to have_many(:allocation_subjects).through(:bursary_subjects) }
  end
end

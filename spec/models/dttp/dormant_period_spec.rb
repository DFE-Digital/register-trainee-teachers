# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe DormantPeriod do
    subject { build(:dttp_dormant_period) }

    it { is_expected.to be_valid }

    describe "relationships" do
      it { is_expected.to belong_to(:placement_assignment).optional }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:response) }
    end
  end
end

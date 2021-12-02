# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe PlacementAssignment do
    subject { build(:dttp_placement_assignment) }

    it { is_expected.to be_valid }

    describe "validations" do
      it { is_expected.to validate_presence_of(:response) }
    end
  end
end

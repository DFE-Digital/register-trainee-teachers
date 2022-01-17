# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe Trainee do
    subject { build(:dttp_trainee) }

    it { is_expected.to be_valid }

    it { is_expected.to have_many(:placement_assignments) }

    describe "validations" do
      it { is_expected.to validate_presence_of(:response) }
    end

    describe "latest_placement_assignment" do
      let(:dttp_trainee) { create(:dttp_trainee) }
      let(:first_placement_assignment) do
        create(:dttp_placement_assignment,
               :with_academic_year_twenty_twenty_one,
               response: create(:api_placement_assignment, modifiedon: 3.hours.ago))
      end
      let(:second_placement_assignment) do
        create(:dttp_placement_assignment,
               :with_academic_year_twenty_twenty_one,
               response: create(:api_placement_assignment, modifiedon: 2.hours.ago))
      end

      before do
        dttp_trainee.placement_assignments << [first_placement_assignment, second_placement_assignment]
      end

      context "in the same academic year" do
        it "sorts by academic year and response->'modifiedon'" do
          expect(dttp_trainee.latest_placement_assignment).to eq(second_placement_assignment)
        end
      end

      context "in different academic years" do
        let(:first_placement_assignment) do
          create(:dttp_placement_assignment,
                 :with_academic_year_twenty_one_twenty_two,
                 response: create(:api_placement_assignment, modifiedon: 1.hour.ago))
        end

        it "sorts by academic year" do
          expect(dttp_trainee.latest_placement_assignment).to eq(first_placement_assignment)
        end
      end
    end
  end
end

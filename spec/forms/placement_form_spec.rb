# frozen_string_literal: true

require "rails_helper"

RSpec::Matchers.define_negated_matcher :not_change, :change

describe PlacementForm, type: :model do
  let(:trainee) { create(:trainee) }

  subject { PlacementForm.new(trainee:) }

  describe "#title" do
    context "when there are no placements" do
      it "returns the _First placement" do
        expect(subject.title).to eq("First placement")
      end
    end

    context "when there are two existing placements" do
      before do
        allow(trainee).to receive(:placements).and_return(build_list(:placement, 2))
      end

      it "returns the _Third placement_" do
        expect(subject.title).to eq("Third placement")
      end
    end
  end

  describe "#save!" do
    context "when a `school_id` for an existing school is given" do
      let!(:school) { create(:school, lead_school: false) }

      subject { PlacementForm.new(trainee: trainee, params: { school_id: school.id }) }

      it "creates a new placement record" do
        expect { subject.save! }.to change { Placement.count }.by(1)
          .and not_change { School.count }

        new_placement = Placement.last

        expect(new_placement.school_id).to eq(school.id)
        expect(new_placement.name).to eq(school.name)
        expect(new_placement.urn).to be_nil
        expect(new_placement.postcode).to be_nil
      end
    end

    context "when details for a new school are given" do
      subject { PlacementForm.new(trainee: trainee, params: { school_id: "", name: "St. Bob's High School", urn: "123456", postcode: "GU1 1AA" }) }

      it "creates a new placement record" do
        expect { subject.save! }.to change { Placement.count }.by(1)
          .and not_change { School.count }

        new_placement = Placement.last

        expect(new_placement.school_id).to be_nil
        expect(new_placement.name).to eq("St. Bob's High School")
        expect(new_placement.urn).to eq("123456")
        expect(new_placement.postcode).to eq("GU1 1AA")
      end
    end
  end
end

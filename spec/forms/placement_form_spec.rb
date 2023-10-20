# frozen_string_literal: true

require "rails_helper"

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
      let(:school) { create(:school) }

      subject { PlacementForm.new(trainee: trainee, params: { school_id: school.id }) }

      it "creates a new placement record" do
        expect { subject.save! }.to change { Placement.count }.by(1)
      end
    end

    context "when details for a new school are given" do
    end
  end
end

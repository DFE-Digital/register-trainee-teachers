# frozen_string_literal: true

require "rails_helper"

RSpec::Matchers.define_negated_matcher :not_change, :change

describe PlacementForm, type: :model do
  let(:trainee) { create(:trainee) }
  let(:store) { FormStore }
  let(:placements_form) { PlacementsForm.new(trainee, store) }
  let(:placement) { Placement.new }

  subject { PlacementForm.new(placements_form:, placement:) }

  describe "#title" do
    context "when there are no placements" do
      it "returns the _First placement" do
        expect(subject.title).to eq("First placement")
      end
    end

    context "when there are two existing placements" do
      let(:trainee) { create(:trainee, placements: build_list(:placement, 2)) }

      it "returns the _Third placement_" do
        expect(subject.title).to eq("Third placement")
      end
    end
  end

  describe "#fields" do
    let(:placement) { Placement.new(name: "Test") }

    it "return fields from initialize" do
      fields = subject.fields
      expect(fields[:name]).to eql("Test")
    end

    it "return fields updated after initialize" do
      fields = subject.fields
      expect(fields[:name]).to eql("Test")
      subject.name = "updated test"
      fields = subject.fields
      expect(fields[:name]).to eql("updated test")
    end
  end

  describe "#attributes" do
    let(:placement) { Placement.new }

    it "return all attributes" do
      subject.attributes = {
        slug: "Test slug",
        name: "Test name",
        postcode: "GU1 1AA",
        urn: 123456,
      }

      expect(subject.attributes).to eql({
        slug: "Test slug",
        school_id: nil,
        name: "Test name",
        postcode: "GU1 1AA",
        urn: 123456,
      })
    end
  end

  describe "#save_or_stash" do
    describe "draft" do
      before do
        allow(trainee).to receive(:draft?).and_return(true)
        allow(subject).to receive(:save!).and_return(true)
      end

      it "save!" do
        expect(subject.save_or_stash).to be_truthy
      end
    end

    describe "not draft" do
      before do
        allow(trainee).to receive(:draft?).and_return(false)
        allow(subject).to receive(:stash).and_return(true)
      end

      it "stashes" do
        expect(subject.save_or_stash).to be_truthy
      end
    end
  end

  describe "#stash" do
    before do
      allow(subject).to receive_messages(fields: { subject: "test1" }, valid?: true)
      allow(placements_form).to receive(:stash_placement_on_store).with(subject.slug, { subject: "test1" })
    end

    it "store placement" do
      expect(subject.stash).to be_present
    end
  end

  describe "#save!" do
    context "creating a new placement" do
      context "when a `school_id` for an existing school is given" do
        let!(:school) { create(:school, lead_school: false) }
        let(:placement) { Placement.new(school_id: school.id) }

        it "creates a new placement record" do
          expect { subject.save! }.to change { Placement.count }.by(1)

          new_placement = Placement.last

          expect(new_placement.school_id).to eq(school.id)
          expect(new_placement.name).to eq(school.name)
          expect(new_placement.urn).to be_nil
          expect(new_placement.postcode).to be_nil
        end
      end

      context "when details for a new school are given" do
        let(:placement) { Placement.new(name: "St. Bob's High School", urn: "123456", postcode: "GU1 1AA") }

        it "creates a new placement record" do
          expect { subject.save! }.to change { Placement.count }.by(1)

          new_placement = Placement.last

          expect(new_placement.school_id).to be_nil
          expect(new_placement.name).to eq("St. Bob's High School")
          expect(new_placement.urn).to eq("123456")
          expect(new_placement.postcode).to eq("GU1 1AA")
        end
      end
    end

    context "deleting a placement record" do
      let(:trainee) { create(:trainee, placements: create_list(:placement, 2)) }
      let(:placement_to_delete) { trainee.placements.first }

      subject do
        PlacementForm.new(
          placements_form: placements_form,
          placement: placement_to_delete,
          destroy: true,
        )
      end

      it "deletes the right placement" do
        expect(Placement.find_by(id: placement_to_delete.id)).to be_present
        expect { subject.save! }.to change { Placement.count }.by(-1)
        expect(Placement.find_by(id: placement_to_delete.id)).to be_nil
      end
    end
  end
end

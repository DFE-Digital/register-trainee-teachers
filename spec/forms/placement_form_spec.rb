# frozen_string_literal: true

require "rails_helper"

describe PlacementForm, type: :model do
  let(:trainee) { create(:trainee) }
  let(:store) { FormStore }
  let(:placements_form) { PlacementsForm.new(trainee, store) }
  let(:placement) { Placement.new }
  let(:placement_form) { described_class.new(placements_form:, placement:) }

  subject { placement_form }

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
        school_search: nil,
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
        let!(:school) { create(:school) }
        let(:placement) { Placement.new(school_id: school.id) }

        it "creates a new placement record" do
          expect { subject.save! }.to change { Placement.count }.by(1)

          new_placement = Placement.last

          expect(new_placement.school_id).to eq(school.id)
          expect(new_placement.name).to eq(school.name)
          expect(new_placement.urn).to eq(school.urn)
          expect(new_placement.postcode).to eq(school.postcode)
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

  describe "#school_name" do
    context "when there are no placements" do
      it "returns nil" do
        expect(subject.school_name).to be_nil
      end
    end

    context "when there are placements" do
      let(:trainee) { create(:trainee, placements: build_list(:placement, 1, :with_school)) }
      let(:placement) { trainee.placements.first }

      it "returns school name" do
        expect(subject.school_name).to be(placement.school.name)
      end
    end
  end

  describe "#update_placement" do
    context "using custom school data" do
      let(:trainee) { create(:trainee, placements: build_list(:placement, 1, :with_school)) }
      let(:placement) { trainee.placements.first }

      let(:attributes) do
        { school_id: nil,
          name: "placement name",
          urn: "123456",
          postcode: "AB1 23D" }
      end

      it "changes the attributes" do
        expect { subject.update_placement(attributes) }
          .to change { subject.school_id }.to(nil)
          .and change { subject.name }
          .to(attributes[:name])
          .and change { subject.urn }
          .to(attributes[:urn])
          .and change { subject.postcode }
          .to(attributes[:postcode])
      end
    end

    context "using school data" do
      let(:school) { create(:school) }
      let(:attributes) do
        { school_id: school.id,
          name: nil,
          urn: nil,
          postcode: nil }
      end

      it "changes the attributes" do
        expect { subject.update_placement(attributes) }
          .to change { subject.school_id }.to(school.id)
      end
    end

    context "when there are placements" do
      let(:trainee) { create(:trainee, placements: build_list(:placement, 1, :with_school)) }
      let(:placement) { trainee.placements.first }

      it "returns school name" do
        expect(subject.school_name).to be(placement.school.name)
      end
    end
  end

  describe "#open_details?" do
    context "with error" do
      context "with urn set" do
        let(:placement) { Placement.new(urn: "123456") }

        before do
          placement_form.valid?
        end

        it "returns true" do
          expect(subject.open_details?).to be_truthy
        end
      end
    end

    context "without error" do
      let(:placement) { Placement.new(name: "name") }

      it "returns false" do
        expect(subject.open_details?).to be_falsey
      end
    end
  end

  describe "validations" do
    describe "#school_valid" do
      it "add errors" do
        expect(subject.errors).to be_empty
        subject.school_valid
        expect(subject.errors).not_to be_empty
        expect(subject.errors.messages[:school_id]).to include("Select an existing school or enter the details for a new school")
      end
    end

    describe "#urn_valid" do
      let(:trainee_placement) { build(:placement, :with_school) }
      let(:trainee) { create(:trainee, placements: [trainee_placement]) }
      let(:placement) { Placement.new(**placement_attributes) }

      context "when the URN is too long" do
        let(:placement_attributes) { { urn: "1234567" } }

        it "adds errors" do
          expect(subject.errors).to be_empty
          subject.urn_valid
          expect(subject.errors).not_to be_empty
          expect(subject.errors.messages[:urn]).to include(
            I18n.t("activemodel.errors.models.placement.attributes.urn.invalid_format"),
          )
        end
      end

      context "when the URN is not numeric" do
        let(:placement_attributes) { { urn: "123a56" } }

        it "adds errors" do
          expect(subject.errors).to be_empty
          subject.urn_valid
          expect(subject.errors).not_to be_empty
          expect(subject.errors.messages[:urn]).to include(
            I18n.t("activemodel.errors.models.placement.attributes.urn.invalid_format"),
          )
        end
      end
    end

    context "urn is set" do
      let(:placement) { Placement.new(urn: "123456") }

      it "validates presence" do
        expect(subject).to validate_presence_of(:name).with_message("Enter a school name")
      end
    end

    context "postcode is set" do
      let(:placement_attributes) { { postcode: "BN1 1AA" } }
      let(:placement) { Placement.new(placement_attributes) }

      it "validates presence" do
        expect(subject).to validate_presence_of(:name).with_message("Enter a school name")
      end

      context "when the postcode is badly formatted" do
        let(:placement_attributes) { { postcode: "567abc" } }

        it "add errors" do
          expect(subject.errors).to be_empty
          subject.postcode_valid
          expect(subject.errors).not_to be_empty
          expect(subject.errors.messages[:postcode]).to include(
            I18n.t("activemodel.errors.validators.postcode.invalid"),
          )
        end
      end
    end
  end
end

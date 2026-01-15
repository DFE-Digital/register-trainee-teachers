# frozen_string_literal: true

require "rails_helper"

describe PlacementsForm, type: :model do
  let(:placements) { [] }
  let(:trainee) { build(:trainee, :submitted_for_trn, placements:) }
  let(:form_store) { class_double(FormStore) }

  subject { described_class.new(trainee, form_store) }

  describe "validations" do
    before do
      allow(form_store).to receive(:get).and_return({})
    end

    context "placements" do
      before do
        subject.valid?
      end

      context "with placements" do
        let(:placements) { build_list(:placement, 2, :with_school) }

        it { is_expected.to be_valid }
      end

      context "with invalid placements" do
        let(:placement_form) { instance_double(PlacementForm) }

        before do
          allow(placement_form).to receive(:invalid?).and_return(true)
          allow(subject).to receive(:placements).and_return([placement_form])
        end

        it { is_expected.not_to be_valid }
      end

      context "with no placements" do
        let(:placements) { [] }

        it "returns an error if its empty" do
          expect(subject.errors[:placement_ids]).to include("Enter at least 2 placements")
        end
      end
    end
  end

  describe "#build_placement_form" do
    let(:template_placement) { build(:placement, :with_school) }

    it "returns new PlacementForm instance" do
      placement_form = subject.build_placement_form(
        name: template_placement.name,
        postcode: template_placement.postcode,
        urn: template_placement.urn,
      )
      expect(placement_form.name).to eql(template_placement.name)
      expect(placement_form.postcode).to eql(template_placement.postcode)
      expect(placement_form.urn).to eql(template_placement.urn)
    end
  end

  describe "#find_placement_from_param" do
    let(:placement1) { build(:placement, trainee:) }
    let(:placement2) { build(:placement, trainee:) }

    before do
      allow(form_store).to receive(:get).and_return(nil)
      trainee.placements << placement1
      trainee.placements << placement2
      trainee.save!
    end

    it "find placement with slug and return PlacementForm instance" do
      expect(trainee.placements.count).to be(2)

      placement_form = subject.find_placement_from_param(placement1.slug)
      expect(placement_form.slug).to eql(placement1.slug)
      expect(placement_form.class).to eql(PlacementForm)
      expect(placement_form.name).to eql(placement1.name)
      expect(placement_form.postcode).to eql(placement1.postcode)
      expect(placement_form.urn).to eql(placement1.urn)
    end

    describe "with stored attributes" do
      before do
        allow(form_store).to receive(:get).and_return({ placement1.slug => { urn: "7777777" } })
      end

      it "find placement with slug and return PlacementForm instance" do
        expect(trainee.placements.count).to be(2)

        placement_form = subject.find_placement_from_param(placement1.slug)
        expect(placement_form.slug).to eql(placement1.slug)
        expect(placement_form.class).to eql(PlacementForm)
        expect(placement_form.name).to eql(placement1.name)
        expect(placement_form.postcode).to eql(placement1.postcode)
        expect(placement_form.urn).to eql("7777777")
      end
    end
  end

  describe "#placements" do
    let(:placement1) { build(:placement, trainee:) }
    let(:placement2) { build(:placement, trainee:) }

    before do
      allow(form_store).to receive(:get).and_return({
        placement2.slug => { name: "Edited name for persisted placement" },
        "XXX111" => { slug: "XXX111", name: "Edited name for new unsaved placement" },
      })
      trainee.placements << placement1
      trainee.placements << placement2
      trainee.save!
    end

    it "returns all placements including stored" do
      placements = subject.placements
      expect(placements.count).to be(3)

      placement_form = placements[0]
      expect(placement_form.slug).to eql(placement1.slug)
      expect(placement_form.class).to eql(PlacementForm)
      expect(placement_form.placement.name).to eql(placement1.name)
      expect(placement_form.name).to eql(placement1.name)
      expect(placement_form.postcode).to eql(placement1.postcode)
      expect(placement_form.urn).to eql(placement1.urn)

      placement_form = placements[1]
      expect(placement_form.slug).to eql(placement2.slug)
      expect(placement_form.class).to eql(PlacementForm)
      expect(placement_form.name).to eql("Edited name for persisted placement")
      expect(placement_form.placement.name).to eql("Edited name for persisted placement")
      expect(placement_form.postcode).to eql(placement2.postcode)
      expect(placement_form.urn).to eql(placement2.urn)

      placement_form = placements[2]
      expect(placement_form.slug).to eql("XXX111")
      expect(placement_form.class).to eql(PlacementForm)
      expect(placement_form.placement.name).to eql("Edited name for new unsaved placement")
      expect(placement_form.name).to eql("Edited name for new unsaved placement")
      expect(placement_form.postcode).to be_blank
      expect(placement_form.urn).to be_blank
    end
  end

  describe "#stash_placement_on_store" do
    describe "empty store" do
      before do
        allow(form_store).to receive(:get).and_return(nil)
        allow(form_store).to receive(:set).with(trainee.id, :placements, {
          "XXX111" => { "name" => "test1" },
        })
      end

      it "store a new placement" do
        expect { subject.stash_placement_on_store("XXX111", { "name" => "test1" }) }.not_to raise_exception
      end
    end

    describe "update placement" do
      before do
        allow(form_store).to receive(:get).and_return({
          "XXX111" => { "name" => "stored placement" },
        })
        allow(form_store).to receive(:set).with(trainee.id, :placements, {
          "XXX111" => { "name" => "test1" },
        })
      end

      it "store a updated placement" do
        expect { subject.stash_placement_on_store("XXX111", { "name" => "test1" }) }.not_to raise_exception
      end
    end

    describe "existing placement" do
      before do
        opts = {
          "XXX111" => { "name" => "stored placement" },
        }
        allow(form_store).to receive(:get).and_return(opts)
        allow(form_store).to receive(:set).with(trainee.id, :placements, opts.merge({
          "XXX112" => { "name" => "test1" },
        }))
      end

      it "store a new placement" do
        expect { subject.stash_placement_on_store("XXX112", { "name" => "test1" }) }.not_to raise_exception
      end
    end
  end

  describe "#delete_placement_on_store" do
    before do
      allow(form_store).to receive(:get).and_return({
        "XXX111" => { "name" => "stored placement1" },
        "XXX112" => { "name" => "stored placement2" },
      })
      allow(form_store).to receive(:set).with(trainee.id, :placements, {
        "XXX112" => { "name" => "stored placement2" },
      })
    end

    it "delete a placement" do
      expect { subject.delete_placement_on_store("XXX111") }.not_to raise_exception
    end
  end

  describe "#save!", feature_integrate_with_trs: true do
    let(:placement_form1) { instance_double(PlacementForm) }
    let(:placement_form2) { instance_double(PlacementForm) }

    before do
      allow(placement_form1).to receive(:save!).and_return(true)
      allow(placement_form2).to receive(:save!).and_return(true)
      allow(subject).to receive(:placements).and_return([placement_form1, placement_form2])
      allow(trainee).to receive(:reload).and_return(trainee)
    end

    it "run save on all the placement form objects" do
      expect(subject.save!).to be_present
    end

    it "does not send an update to TRS" do
      expect(Trainees::Update).not_to receive(:call)
      subject.save!
    end

    context "if trainee has not provided placement detail" do
      let(:trainee) { build(:trainee, :submitted_for_trn, :no_placement_detail, placements:) }

      it "updates them to have placement detail" do
        expect { subject.save! }.to change(trainee, :placement_detail).from("no_placement_detail").to("has_placement_detail")
      end
    end
  end
end

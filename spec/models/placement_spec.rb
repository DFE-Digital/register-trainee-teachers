# frozen_string_literal: true

require "rails_helper"

RSpec.describe Placement do
  let(:trainee) { create(:trainee) }

  context "validations" do
    context "when a school exists" do
      subject { described_class.new(trainee: trainee, school: create(:school)) }

      it { is_expected.to be_valid }
    end

    context "when a school does not exist" do
      context "when name, address and postcode are provided" do
        subject {
          described_class.new(trainee: trainee, name: "Some name", address: "Some address", postcode: "Some postcode")
        }

        it { is_expected.to be_valid }
      end

      context "when name is missing" do
        subject {
          described_class.new(trainee: trainee, name: nil)
        }

        it { is_expected.not_to be_valid }
      end
    end
  end

  describe "#name" do
    context "when a school record exists" do
      subject { create(:placement) }

      it "returns the school name" do
        expect(subject.name).to eq(subject.school.name)
      end
    end

    context "when a school record does not exist" do
      subject {
        create(:placement, :manual, name: "Some name")
      }

      it "returns the school name" do
        expect(subject.name).to eq("Some name")
      end
    end
  end

  describe "#address" do
    context "when a school record exists" do
      subject { create(:placement) }

      it "returns the school address" do
        expect(subject.full_address).to eq("URN #{subject.school.urn}, #{subject.school.town}, #{subject.school.postcode}")
      end
    end

    context "when a school record does not exist and no urn is provided by user" do
      subject {
        create(:placement, :manual, urn: nil)
      }

      it "returns the user input address" do
        expect(subject.full_address).to eq("#{subject.address}, #{subject.postcode}")
      end
    end

    context "when a school record does not exist but urn is provided by user" do
      subject {
        create(:placement, :manual)
      }

      it "returns the user input address" do
        expect(subject.full_address).to eq("URN #{subject.urn}, #{subject.address}, #{subject.postcode}")
      end
    end

    context "when the school urn is among the Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS" do
      subject {
        create(:placement, :manual, urn: Trainees::CreateFromHesa::NOT_APPLICABLE_SCHOOL_URNS.sample)
      }

      it "returns no address" do
        expect(subject.full_address).to be_nil
      end
    end
  end
end

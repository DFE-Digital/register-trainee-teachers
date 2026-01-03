# frozen_string_literal: true

require "rails_helper"

RSpec.describe Placement do
  let(:trainee) { create(:trainee) }

  describe "default scope" do
    it { expect(described_class.all.to_sql).to eq(described_class.order(created_at: :asc).to_sql) }
  end

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

    context "when a placement with the same urn and trainee_id already exists" do
      let(:placement) { create(:placement) }
      let(:trainee) { placement.trainee }

      subject {
        described_class.new(trainee: trainee, urn: placement.urn)
      }

      it { is_expected.not_to be_valid }
    end

    context "when a placement with the same address and postcode and trainee_id already exists" do
      let(:placement) { create(:placement) }
      let(:trainee) { placement.trainee }

      subject {
        described_class.new(trainee: trainee, address: placement.address, postcode: placement.postcode)
      }

      it { is_expected.not_to be_valid }
    end

    context "when a placement with the same school and trainee_id already exists" do
      let(:placement) { create(:placement) }
      let(:trainee) { placement.trainee }

      subject {
        described_class.new(trainee: trainee, school: placement.school)
      }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#name" do
    context "when a school record exists" do
      subject { create(:placement, :with_school) }

      context "with name column value nil" do
        it "returns the school name" do
          expect(subject.name).to eq(subject.school.name)
        end
      end

      context "with name column value present" do
        let(:name) { Faker::Educator.primary_school }

        before do
          subject.update!(name:)
        end

        it "returns the school name" do
          expect(subject.name).to eq(subject.school.name)
        end
      end
    end

    context "when a school record does not exist" do
      subject {
        create(:placement, name: "Some name")
      }

      it "returns the school name" do
        expect(subject.name).to eq("Some name")
      end
    end
  end

  describe "#urn" do
    context "when a school record exists" do
      subject { create(:placement, :with_school) }

      context "with urn column value nil" do
        it "returns the school urn" do
          expect(subject.urn).to eq(subject.school.urn)
        end
      end

      context "with urn column value present" do
        let(:urn) { Faker::Number.unique.number(digits: 6).to_s }

        before do
          subject.update!(urn:)
        end

        it "returns the school urn" do
          expect(subject.urn).to eq(subject.school.urn)
        end
      end
    end

    context "when a school record does not exist" do
      subject {
        create(:placement, urn:)
      }

      let(:urn) { Faker::Number.unique.number(digits: 6).to_s }

      it "returns the urn column value" do
        expect(subject.urn).to eq(urn)
      end
    end
  end

  describe "#postcode" do
    context "when a school record exists" do
      subject { create(:placement, :with_school) }

      context "with postcode column value nil" do
        it "returns the school name" do
          expect(subject.postcode).to eq(subject.school.postcode)
        end
      end

      context "with postcode column value present" do
        let(:postcode) { Faker::Address.postcode }

        before do
          subject.update!(postcode:)
        end

        it "returns the school postcode" do
          expect(subject.postcode).to eq(subject.school.postcode)
        end
      end
    end

    context "when a school record does not exist" do
      subject {
        create(:placement, postcode:)
      }

      let(:postcode) { Faker::Address.postcode }

      it "returns the postcode column value" do
        expect(subject.postcode).to eq(postcode)
      end
    end
  end

  describe "#full_address" do
    let(:address) { Faker::Address.street_address }

    context "when a school record exists" do
      subject { create(:placement, :with_school) }

      it "returns the school address" do
        expect(subject.full_address).to eq("URN #{subject.school.urn}, #{subject.school.town}, #{subject.school.postcode}")
      end
    end

    context "when a school record does not exist and no urn is provided by user" do
      subject {
        create(:placement, address: address, urn: nil)
      }

      it "returns the user input address" do
        expect(subject.full_address).to eq("#{subject.address}, #{subject.postcode}")
      end
    end

    context "when a school record does not exist but urn is provided by user" do
      subject {
        create(:placement, address:, urn:)
      }

      let(:urn) { Faker::Number.number(digits: 6) }

      it "returns the user input address" do
        expect(subject.full_address).to eq("URN #{urn}, #{subject.address}, #{subject.postcode}")
      end
    end

    context "when the school urn is among the Trainee::NOT_APPLICABLE_SCHOOL_URNS" do
      subject {
        create(:placement, urn: Trainee::NOT_APPLICABLE_SCHOOL_URNS.sample)
      }

      it "returns no address" do
        expect(subject.full_address).to be_nil
      end
    end
  end

  describe "scopes" do
    describe "::with_school" do
      let!(:placement) { create(:placement) }
      let!(:placement_with_school) { create(:placement, :with_school) }

      it "returns only the trainees with a school" do
        expect(Placement.with_school).to contain_exactly(placement_with_school)
      end
    end
  end
end

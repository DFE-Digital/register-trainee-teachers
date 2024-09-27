# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::PlacementAttributes do
  subject { described_class.new(params) }

  let!(:school) { create(:school) }

  describe "validations" do
    context "when urn is present" do
      context "with a valid urn" do
        let(:params) do
          {
            urn: school.urn,
          }
        end

        it "sets the attributes from the school" do
          expect(subject).to be_valid
          expect(subject.errors).to be_empty
          expect(subject.school_id).to eq(school.id)
          expect(subject.urn).to eq(school.urn)
          expect(subject.name).to eq(school.name)
          expect(subject.postcode).to eq(school.postcode)
        end

        context "with name, postcode, address specified" do
          let(:name) { Faker::Educator.primary_school }
          let(:postcode) { Faker::Address.postcode }
          let(:address) { Faker::Address.street_address }

          before do
            params.merge!(
              name:,
              postcode:,
              address:,
            )
          end

          it "sets the attributes" do
            expect(subject).to be_valid
            expect(subject.name).to eq(name)
            expect(subject.postcode).to eq(postcode)
            expect(subject.address).to eq(address)
          end
        end
      end

      context "with an invalid urn" do
        let(:params) do
          {
            urn: Faker::Number.number(digits: 5).to_s,
          }
        end

        it "adds an error on urn" do
          expect(subject).not_to be_valid
          expect(subject.errors[:urn]).to contain_exactly("is invalid")
        end
      end
    end

    context "when urn is blank" do
      let(:params) do
        {
          urn: "",
        }
      end

      context "with a name" do
        let(:name) { Faker::Educator.university }

        before do
          params.merge!(name:)
        end

        it "is valid" do
          expect(subject).to be_valid
          expect(subject.errors).to be_empty
          expect(subject.name).to eq(name)
        end
      end

      context "without a name" do
        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:name]).to contain_exactly("can't be blank")
        end
      end
    end

    context "when postcode is present" do
      context "with a valid postcode" do
        let(:params) do
          {
            name: Faker::Educator.university,
            postcode: "SW1A 1AA",
          }
        end

        it "is valid with a correct postcode" do
          expect(subject).to be_valid
          expect(subject.errors).to be_empty
        end
      end

      context "with an invalid postcode" do
        let(:params) do
          {
            name: Faker::Educator.university,
            postcode: "invalid_postcode",
          }
        end

        it "validates format of postcode" do
          expect(subject).not_to be_valid
          expect(subject.errors[:postcode]).to contain_exactly(
            I18n.t("activemodel.errors.validators.postcode.invalid"),
          )
        end
      end
    end
  end

  describe "attributes" do
    describe "#address" do
      let(:address) { Faker::Address.street_address }
      let(:params) do
        {
          name: Faker::Educator.university,
          address: address,
        }
      end

      it "sets the address" do
        expect(subject.address).to eq(address)
      end
    end

    describe "#school_id" do
      let(:params) do
        {
          name: Faker::Educator.university,
          school_id: school.id,
        }
      end

      it "does not set it" do
        expect(subject).to be_valid
        expect(subject.school_id).to be_nil
      end
    end
  end
end

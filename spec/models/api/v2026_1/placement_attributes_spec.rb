# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::PlacementAttributes do
  subject { described_class.new(params) }

  describe "validations" do
    let(:school) { create(:school) }

    context "when urn is present" do
      context "with a valid urn" do
        let(:params) do
          {
            urn:,
          }.stringify_keys
        end

        context "with a School matching the urn" do
          let(:urn) { school.urn }

          it "sets the attributes from the school" do
            expect(subject).to be_valid
            expect(subject.errors).to be_empty
            expect(subject.school_id).to eq(school.id)
            expect(subject.urn).to be_nil
            expect(subject.name).to be_nil
            expect(subject.postcode).to be_nil
          end
        end

        context "with name and postcode specified" do
          let(:urn) { Faker::Number.unique.number(digits: 6).to_s }
          let(:name) { Faker::Educator.primary_school }
          let(:postcode) { Faker::Address.postcode }

          before do
            params.merge!(
              name:,
              postcode:,
            )
          end

          it "sets the attributes" do
            expect(subject).to be_valid
            expect(subject.urn).to eq(urn)
            expect(subject.name).to eq(name)
            expect(subject.postcode).to eq(postcode)
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
        }.stringify_keys
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
    let(:school) { create(:school) }

    let(:params) do
      {
        urn: school.urn,
        school_id: school.id,
        name: school.name,
        postcode: school.postcode,
      }.stringify_keys
    end

    it "sets the ATTRIBUTES and INTERNAL_ATTRIBUTES" do
      expect(subject.attributes).to eq(params)
    end
  end
end

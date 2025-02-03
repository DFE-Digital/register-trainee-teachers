# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::DegreeAttributes do
  let(:degree) { build(:degree) }
  let(:trainee) { create(:trainee, :with_degree) }
  let(:degree_attributes) { described_class.new(attributes, trainee:) }
  let(:attributes_with_id) { degree.attributes.with_indifferent_access.slice(*described_class::ATTRIBUTES) }
  let(:attributes) { attributes_with_id.except(:id) }

  subject { degree_attributes }

  describe "validations" do
    it { is_expected.to validate_presence_of(:locale_code) }
    it { is_expected.to validate_presence_of(:graduation_year) }
    it { is_expected.to validate_presence_of(:subject) }

    context 'when locale_code is "uk"' do
      before { degree_attributes.locale_code = "uk" }

      it { is_expected.to validate_presence_of(:institution) }
      it { is_expected.to validate_presence_of(:uk_degree) }
      it { is_expected.to validate_presence_of(:grade) }
    end

    context 'when locale_code is "non_uk"' do
      before { degree_attributes.locale_code = "non_uk" }

      it { is_expected.to validate_presence_of(:country) }

      it {
        expect(subject).to validate_inclusion_of(:country).in_array(
          Hesa::CodeSets::Countries::MAPPING.values,
        )
      }

      it { is_expected.to validate_presence_of(:non_uk_degree) }

      it {
        expect(subject).to validate_inclusion_of(:non_uk_degree).in_array(
          DfEReference::DegreesQuery::TYPES.all.map(&:name),
        )
      }
    end

    context "with duplicate" do
      before { subject.valid? }

      let(:degree) { trainee.degrees.first }

      describe "validations" do
        it "returns an error for base duplicates" do
          expect(subject.errors[:base]).to contain_exactly("This is a duplicate degree")
        end
      end
    end

    context "without duplicate" do
      before { subject.valid? }

      describe "validations" do
        it "returns no error for base duplicates" do
          expect(subject.errors[:base]).to be_blank
        end
      end
    end
  end

  describe "#duplicates?" do
    subject { degree_attributes.duplicates? }

    context "with duplicate" do
      let(:degree) { trainee.degrees.first }

      it "returns true" do
        expect(subject).to be_truthy
      end
    end

    context "without duplicate" do
      it "returns false" do
        expect(subject).to be_falsey
      end
    end
  end
end

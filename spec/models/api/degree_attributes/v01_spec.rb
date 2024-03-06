# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::DegreeAttributes::V01 do
  let(:v01) { described_class.new(attributes, existing_degrees:) }
  let(:existing_degrees) { Degree }
  let(:degree) { build(:degree) }
  let(:attributes) { degree.attributes.with_indifferent_access.slice(*described_class::ATTRIBUTES) }

  subject { v01 }

  describe "validations" do
    it { expect(subject).to validate_inclusion_of(:institution).in_array(DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:name)).allow_nil }
    it { expect(subject).to validate_inclusion_of(:subject).in_array(DfEReference::DegreesQuery::SUBJECTS.all.map(&:name)).allow_nil }
    it { expect(subject).to validate_inclusion_of(:uk_degree).in_array(DfEReference::DegreesQuery::TYPES.all.map(&:name)).allow_nil }

    context "with duplicate" do
      let(:degree) { create(:degree) }

      before { subject.valid? }

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
    subject { v01.duplicates? }

    context "with duplicate" do
      let(:degree) { create(:degree) }

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

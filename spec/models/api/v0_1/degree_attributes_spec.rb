# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::DegreeAttributes do
  let(:v01) { described_class.new(attributes, trainee:) }
  let(:attributes_with_id) { Api::V01::DegreeSerializer.new(degree).as_hash.with_indifferent_access.slice(*described_class::ATTRIBUTES) }
  let(:degree) { build(:degree) }

  let(:attributes) { attributes_with_id }
  let(:trainee) { create(:trainee, :with_degree) }

  subject { v01 }

  describe "validations" do
    it { expect(subject).to validate_inclusion_of(:institution).in_array(DfEReference::DegreesQuery::INSTITUTIONS.all.map(&:hesa_itt_code)).allow_nil }
    it { expect(subject).to validate_inclusion_of(:subject).in_array(DfEReference::DegreesQuery::SUBJECTS.all.map(&:hecos_code)).allow_nil }
    it { expect(subject).to validate_inclusion_of(:uk_degree).in_array(DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code)).allow_nil }

    context "with duplicate" do
      before { subject.valid? }

      let(:attributes) { attributes_with_id.except(:id) }
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
    subject { v01.duplicates? }

    context "with duplicate" do
      let(:attributes) { attributes_with_id.except(:id) }
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

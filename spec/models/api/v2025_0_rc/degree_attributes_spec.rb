# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20250Rc::DegreeAttributes do
  include ErrorMessageHelper

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

    it {
      expect(subject).to validate_inclusion_of(:country)
        .in_array(Hesa::CodeSets::Countries::MAPPING.values)
        .with_message(/has invalid reference data value of '.*'/)
    }

    context 'when locale_code is "uk"' do
      before { degree_attributes.locale_code = "uk" }

      it { is_expected.to validate_presence_of(:institution) }
      it { is_expected.to validate_presence_of(:grade) }

      describe "uk_degree" do
        context "when empty" do
          before { subject.uk_degree = "" }

          it {
            subject.validate

            expect(subject.errors[:uk_degree]).to contain_exactly("must be entered if specifying a previous UK degree")
          }
        end

        context "when nil" do
          before { subject.uk_degree = nil }

          it {
            subject.validate

            expect(subject.errors[:uk_degree]).to contain_exactly("must be entered if specifying a previous UK degree")
          }
        end

        context "when not included in the list of HESA uk degrees" do
          before { subject.uk_degree = "Random subject" }

          it {
            subject.validate

            expect(subject.errors[:uk_degree]).to contain_exactly(
              "has invalid reference data value of 'Random subject'. Example values include #{format_reference_data_list(DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq)}...",
            )
          }
        end

        context "when included in the list of HESA uk degrees" do
          DfEReference::DegreesQuery::TYPES.all.map(&:name).each do |name|
            before { subject.uk_degree = name }

            it "is expected to allow #{name}" do
              subject.validate

              expect(subject.errors[:uk_degree]).to be_blank
            end
          end
        end
      end
    end

    context 'when locale_code is "non_uk"' do
      before { degree_attributes.locale_code = "non_uk" }

      it { is_expected.to validate_presence_of(:country) }

      describe "non_uk_degree" do
        context "when empty" do
          before { subject.non_uk_degree = "" }

          it {
            subject.validate

            expect(subject.errors[:non_uk_degree]).to contain_exactly("must be entered if specifying a previous non-UK degree")
          }
        end

        context "when nil" do
          before { subject.non_uk_degree = nil }

          it {
            subject.validate

            expect(subject.errors[:non_uk_degree]).to contain_exactly("must be entered if specifying a previous non-UK degree")
          }
        end

        context "when not included in the list of HESA non uk degrees" do
          before { subject.non_uk_degree = "Random subject" }

          it {
            subject.validate

            expect(subject.errors[:non_uk_degree]).to contain_exactly(
              "has invalid reference data value of 'Random subject'. Example values include #{format_reference_data_list(DfEReference::DegreesQuery::TYPES.all.map(&:hesa_itt_code).compact.uniq)}...",
            )
          }
        end

        context "when included in the list of HESA non uk degrees" do
          DfEReference::DegreesQuery::TYPES.all.map(&:name).each do |name|
            before { subject.non_uk_degree = name }

            it "is expected to allow #{name}" do
              subject.validate

              expect(subject.errors[:non_uk_degree]).to be_blank
            end
          end
        end
      end
    end

    context "with duplicate" do
      before { subject.validate }

      let(:degree) { trainee.degrees.first }

      describe "validations" do
        it "returns an error for base duplicates" do
          expect(subject.errors[:base]).to contain_exactly("This is a duplicate degree")
        end
      end
    end

    context "without duplicate" do
      before { subject.validate }

      describe "validations" do
        it "returns no error for base duplicates" do
          expect(subject.errors[:base]).to be_blank
        end
      end
    end
  end

  describe "duplicates" do
    context "with duplicate" do
      let(:degree) { trainee.degrees.first }

      it "returns the duplicate degrees" do
        expect(subject.duplicates).to contain_exactly(degree)
      end
    end

    context "without duplicate" do
      it "returns no duplicate degrees" do
        expect(subject.duplicates).to be_empty
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

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V01::HesaTraineeDetailAttributes do
  subject { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:course_year) }
    it { is_expected.to validate_presence_of(:fund_code) }

    describe "itt_aim" do
      it { is_expected.to validate_presence_of(:itt_aim) }

      context "when included in the list of HESA itt aim codes" do
        Hesa::CodeSets::IttAims::MAPPING.keys.each do |itt_aim|
          subject { described_class.new(itt_aim: ) }

          it {
            expect(subject).not_to be_valid
            expect(subject.errors[:itt_aim]).to be_blank
          }
        end
      end

      context "when not included in the list of HESA itt aim codes" do
        subject { described_class.new(itt_aim: "300") }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:itt_aim]).to contain_exactly("has invalid reference data values")
        }
      end
    end

    describe "itt_qualification_aim" do
      context "when empty" do
        subject { described_class.new(itt_qualification_aim: "") }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:itt_qualification_aim]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(itt_qualification_aim: nil) }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:itt_qualification_aim]).to contain_exactly("can't be blank")
        }
      end

      context "when included in the list of HESA itt qualification aim codes" do
        ::Hesa::CodeSets::IttQualificationAims::MAPPING.keys.each do |itt_qualification_aim|
          subject { described_class.new(itt_qualification_aim: ) }

          it {
            expect(subject).not_to be_valid
            expect(subject.errors[:itt_qualification_aim]).to be_blank
          }
        end
      end

      context "when not included in the list of HESA itt qualification aim codes" do
        subject { described_class.new(itt_qualification_aim: "300") }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:itt_qualification_aim]).to contain_exactly("has invalid reference data values")
        }
      end
    end

    describe "course_age_range" do
      it { is_expected.to validate_presence_of(:course_age_range) }

      it {
        expect(subject).to validate_inclusion_of(:course_age_range)
          .in_array(Hesa::CodeSets::AgeRanges::MAPPING.keys)
      }
    end

    describe "funding_method" do
      context "when empty" do
        subject { described_class.new(funding_method: "") }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:funding_method]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(funding_method: nil) }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:funding_method]).to contain_exactly("can't be blank")
        }
      end

      context "when not included in the list of HESA bursary levels" do
        subject { described_class.new(funding_method: "AD") }

        it {
          expect(subject).not_to be_valid
          expect(subject.errors[:funding_method]).to contain_exactly("has invalid reference data values")
        }
      end

      context "when included in the list of HESA bursary levels" do
        Hesa::CodeSets::BursaryLevels::MAPPING.each_key do |funding_method|
          subject { described_class.new(funding_method:) }

          it "is expected to allow #{funding_method}" do
            expect(subject).not_to be_valid
            expect(subject.errors[:funding_method]).to be_blank
          end
        end
      end
    end
  end
end

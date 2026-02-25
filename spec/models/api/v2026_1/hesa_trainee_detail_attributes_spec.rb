# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V20261::HesaTraineeDetailAttributes do
  include ErrorMessageHelper

  subject { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:course_year) }
    it { is_expected.to validate_presence_of(:fund_code) }

    describe "itt_aim" do
      it { is_expected.to validate_presence_of(:itt_aim) }

      context "when included in the list of HESA itt aim codes" do
        Hesa::CodeSets::IttAims::MAPPING.each_key do |itt_aim|
          subject { described_class.new(itt_aim:) }

          it {
            subject.validate

            expect(subject.errors[:itt_aim]).to be_blank
          }
        end
      end

      context "when not included in the list of HESA itt aim codes" do
        subject { described_class.new(itt_aim: "300") }

        it {
          subject.validate

          expect(subject.errors[:itt_aim]).to contain_exactly(
            "has invalid reference data value of '300'. Valid values are #{Hesa::CodeSets::IttAims::MAPPING.keys.map { |v| "'#{v}'" }.join(', ')}.",
          )
        }
      end
    end

    describe "itt_qualification_aim" do
      context "when itt_aim is nil" do
        it { is_expected.to validate_presence_of(:itt_qualification_aim) }
      end

      context "when itt_aim is 202" do
        before do
          subject.itt_aim = "202"
        end

        it { is_expected.to validate_presence_of(:itt_qualification_aim) }
      end

      context "when itt_aim is 201" do
        before do
          subject.itt_aim = "201"
        end

        it { is_expected.not_to validate_presence_of(:itt_qualification_aim) }
      end

      context "when included in the list of HESA itt qualification aim codes" do
        Hesa::CodeSets::IttQualificationAims::MAPPING.each_key do |itt_qualification_aim|
          subject { described_class.new(itt_qualification_aim:) }

          it {
            subject.validate

            expect(subject.errors[:itt_qualification_aim]).to be_blank
          }
        end
      end

      context "when not included in the list of HESA itt qualification aim codes" do
        subject { described_class.new(itt_qualification_aim: "300") }

        it {
          subject.validate

          expect(subject.errors[:itt_qualification_aim]).to contain_exactly(
            "has invalid reference data value of '300'. Example values include #{format_reference_data_list(Hesa::CodeSets::IttQualificationAims::MAPPING.keys)}...",
          )
        }
      end
    end

    describe "course_age_range" do
      it { is_expected.to validate_presence_of(:course_age_range) }

      it {
        expect(subject).to validate_inclusion_of(:course_age_range)
          .in_array(Hesa::CodeSets::AgeRanges::MAPPING.keys)
          .with_message(/has invalid reference data value of '.*'/)
      }
    end

    describe "funding_method" do
      context "when empty" do
        subject { described_class.new(funding_method: "") }

        it {
          subject.validate

          expect(subject.errors[:funding_method]).to contain_exactly("can't be blank")
        }
      end

      context "when nil" do
        subject { described_class.new(funding_method: nil) }

        it {
          subject.validate

          expect(subject.errors[:funding_method]).to contain_exactly("can't be blank")
        }
      end

      context "when not included in the list of HESA bursary levels" do
        subject { described_class.new(funding_method: "AD") }

        it {
          subject.validate

          expect(subject.errors[:funding_method]).to contain_exactly(
            "has invalid reference data value of 'AD'. Valid values are #{Hesa::CodeSets::BursaryLevels::MAPPING.keys.map { |v| "'#{v}'" }.join(', ')}.",
          )
        }
      end

      context "when included in the list of HESA bursary levels" do
        Hesa::CodeSets::BursaryLevels::MAPPING.each_key do |funding_method|
          subject { described_class.new(funding_method:) }

          it "is expected to allow #{funding_method}" do
            subject.validate

            expect(subject.errors[:funding_method]).to be_blank
          end
        end
      end
    end

    describe "fund_code" do
      context "when not included in the list of HESA fund codes" do
        subject { described_class.new(fund_code: "9") }

        it {
          subject.validate

          expect(subject.errors[:fund_code]).to contain_exactly(
            "has invalid reference data value of '9'. Valid values are #{Hesa::CodeSets::FundCodes::MAPPING.keys.map { |v| "'#{v}'" }.join(', ')}.",
          )
        }
      end

      context "when included in the list of HESA fund codes" do
        Hesa::CodeSets::FundCodes::MAPPING.each_key do |fund_code|
          subject { described_class.new(fund_code:) }

          it "is expected to allow #{fund_code}" do
            subject.validate

            expect(subject.errors[:fund_code]).to be_blank
          end
        end
      end
    end

    describe "course_year" do
      context "when not an integer" do
        subject { described_class.new(course_year: "abc") }

        it {
          subject.validate

          expect(subject.errors[:course_year]).to contain_exactly("is not a valid course year")
        }
      end

      context "when a valid integer" do
        subject { described_class.new(course_year: "1") }

        it {
          subject.validate

          expect(subject.errors[:course_year]).to be_blank
        }
      end

      context "when blank" do
        subject { described_class.new(course_year: "") }

        it {
          subject.validate

          expect(subject.errors[:course_year]).to contain_exactly("can't be blank")
        }
      end
    end

    describe "additional_training_initiative" do
      context "when not included in the list of HESA training initiative codes" do
        subject { described_class.new(additional_training_initiative: "now_teach") }

        it {
          subject.validate

          expect(subject.errors[:additional_training_initiative]).to contain_exactly(
            "has invalid reference data value of 'now_teach'. Valid values are #{Hesa::CodeSets::TrainingInitiatives::MAPPING.keys.map { |v| "'#{v}'" }.join(', ')}.",
          )
        }
      end

      context "when included in the list of HESA training initiative codes" do
        Hesa::CodeSets::TrainingInitiatives::MAPPING.each_key do |additional_training_initiative|
          subject { described_class.new(additional_training_initiative:) }

          it "is expected to allow #{additional_training_initiative}" do
            subject.validate

            expect(subject.errors[:additional_training_initiative]).to be_blank
          end
        end
      end

      context "when blank" do
        subject { described_class.new(additional_training_initiative: "") }

        it {
          subject.validate

          expect(subject.errors[:additional_training_initiative]).to be_blank
        }
      end
    end
  end
end

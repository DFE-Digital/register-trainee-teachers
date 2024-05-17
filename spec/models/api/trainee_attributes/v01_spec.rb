# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::TraineeAttributes::V01 do
  subject { described_class.new }

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_names) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:sex) }
    it { is_expected.to validate_presence_of(:training_route) }
    it { is_expected.to validate_presence_of(:itt_start_date) }
    it { is_expected.to validate_presence_of(:itt_end_date) }
    it { is_expected.to validate_presence_of(:diversity_disclosure) }
    it { is_expected.to validate_presence_of(:course_subject_one) }
    it { is_expected.to validate_presence_of(:study_mode) }
    it { is_expected.to validate_presence_of(:hesa_id) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }

    it { is_expected.to validate_inclusion_of(:sex).in_array(Hesa::CodeSets::Sexes::MAPPING.values) }
    it { is_expected.to validate_inclusion_of(:ethnicity).in_array(Hesa::CodeSets::Ethnicities::MAPPING.keys).allow_nil }
  end

  describe ".from_trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :completed, sex: :prefer_not_to_say) }

    subject(:attributes) { described_class.from_trainee(trainee) }

    it "pulls HesaTraineeDetail attributes from association" do
      expect(attributes.hesa_trainee_detail_attributes).to be_present

      Api::HesaTraineeDetailAttributes::V01::ATTRIBUTES.each do |attr|
        expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
      end
    end

    it "correctly sets the sex attribute as an integer" do
      expect(attributes.sex).to eq(Trainee.sexes[:prefer_not_to_say])
    end
  end

  describe "#deep_attributes" do
    let(:params) do
      {
        first_names: "Orval",
        last_name: "Erdman",
        email: "Orval.Erdman@example.com",
        middle_names: "Strosin",
        training_route: "assessment_only",
        sex: "prefer_not_to_say",
        diversity_disclosure: "diversity_not_disclosed",
        ethnic_group: nil,
        ethnic_background: nil,
        disability_disclosure: nil,
        course_subject_one: "mathematics",
        trn: nil,
        course_subject_two: nil,
        course_subject_three: nil,
        study_mode: "full_time",
        application_choice_id: nil,
        previous_last_name: "Mueller",
        itt_aim: "201",
        course_study_mode: "01",
        course_year: 2024,
        course_age_range: "13918",
        pg_apprenticeship_start_date: 2.months.from_now.iso8601,
        funding_method: "13919",
        ni_number: "QQ 12 34 56 C",
      }
    end

    subject(:attributes) { described_class.new(params) }

    it "wraps all hesa trainee detail attributes" do
      deep_attributes = attributes.deep_attributes.with_indifferent_access

      expect(deep_attributes).to have_key(:hesa_trainee_detail_attributes)
    end
  end

  describe "assign_attributes" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :completed, sex: :prefer_not_to_say) }
    let(:trainee_attributes) { described_class.from_trainee(trainee) }

    subject(:attributes) {
      trainee_attributes
    }

    it "correctly sets the sex attribute as an integer" do
      expect(attributes.sex).to eq(Trainee.sexes[trainee.sex])

      expect {
        attributes.assign_attributes(sex: 3)
      }.to change {
        attributes.sex
      }.from(4).to(3)
    end

    context "hesa trainee detail attributes" do
      context "changing a non hesa trainee detail attributes" do
        it "does not change the hesa trainee detail attributes" do
          expect(attributes.sex).to eq(Trainee.sexes[:prefer_not_to_say])

          expect {
            attributes.assign_attributes(sex: 3)
          }.not_to change {
            attributes.hesa_trainee_detail_attributes
          }
        end
      end

      context "changing a single hesa trainee detail attribute" do
        let(:trainee) { create(:trainee, :with_hesa_student, :completed, sex: :prefer_not_to_say, hesa_trainee_detail: hesa_trainee_detail) }

        let(:hesa_trainee_detail) {
          build(:hesa_trainee_detail, course_age_range: "13909")
        }

        let(:hesa_trainee_detail_attributes) {
          hesa_trainee_detail.attributes.select { |k, _v|
            Api::HesaTraineeDetailAttributes::V01::ATTRIBUTES.include?(k.to_sym)
          }
        }

        let(:updated_hesa_trainee_detail_attributes) {
          hesa_trainee_detail_attributes.merge("course_age_range" => "13919")
        }

        it "does not change the other hesa trainee detail attributes" do
          expect(attributes.hesa_trainee_detail_attributes.attributes).to match(hesa_trainee_detail_attributes)

          expect {
            attributes.assign_attributes(course_age_range: "13919")
          }.to change {
            attributes.hesa_trainee_detail_attributes.attributes
          }.from(hesa_trainee_detail_attributes).to(updated_hesa_trainee_detail_attributes)
        end
      end
    end
  end
end

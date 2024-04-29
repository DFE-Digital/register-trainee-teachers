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
  end

  describe ".from_trainee" do
    let(:trainee) { create(:trainee, :with_hesa_trainee_detail, :completed) }

    subject(:attributes) { described_class.from_trainee(trainee) }

    it "pulls HesaTraineeDetail attributes from association" do
      expect(attributes.hesa_trainee_detail_attributes).to be_present

      Api::HesaTraineeDetailAttributes::V01::ATTRIBUTES.each do |attr|
        expect(attributes.hesa_trainee_detail_attributes.send(attr)).to be_present
      end
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
        postgrad_apprenticeship_start_date: 2.months.from_now.iso8601,
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
end

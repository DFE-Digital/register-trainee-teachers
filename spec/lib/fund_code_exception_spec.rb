# frozen_string_literal: true

require "rails_helper"

describe FundCodeException do
  describe "::applies_to?" do
    subject { described_class.applies_to?(allocation_subject:, academic_cycle:) }

    let(:allocation_subject) { instance_double(AllocationSubject, name: subject_name) }
    let(:academic_cycle) { instance_double(AcademicCycle, start_year:) }

    context "when the subject is in the exception list and the cycle starts in 2025" do
      let(:subject_name) { AllocationSubjects::PHYSICS }
      let(:start_year) { 2025 }

      it { is_expected.to be true }
    end

    context "when the subject is in the exception list and the cycle starts in 2026" do
      let(:subject_name) { AllocationSubjects::PHYSICS }
      let(:start_year) { 2026 }

      it { is_expected.to be true }
    end

    context "when the subject is in the exception list but the cycle starts in 2024" do
      let(:subject_name) { AllocationSubjects::PHYSICS }
      let(:start_year) { 2024 }

      it { is_expected.to be false }
    end

    context "when the subject is in the exception list but the cycle starts in 2027" do
      let(:subject_name) { AllocationSubjects::PHYSICS }
      let(:start_year) { 2027 }

      it { is_expected.to be false }
    end

    context "when the subject is not in the exception list and the cycle starts in 2026" do
      let(:subject_name) { AllocationSubjects::BIOLOGY }
      let(:start_year) { 2026 }

      it { is_expected.to be false }
    end

    [
      AllocationSubjects::ANCIENT_LANGUAGES,
      AllocationSubjects::MODERN_LANGUAGES,
      AllocationSubjects::FRENCH_LANGUAGE,
      AllocationSubjects::GERMAN_LANGUAGE,
      AllocationSubjects::SPANISH_LANGUAGE,
      AllocationSubjects::PHYSICS,
    ].each do |name|
      context "when the subject is #{name} and the cycle starts in 2026" do
        let(:subject_name) { name }
        let(:start_year) { 2026 }

        it { is_expected.to be true }
      end
    end

    context "when the allocation_subject is nil" do
      let(:allocation_subject) { nil }
      let(:academic_cycle) { instance_double(AcademicCycle, start_year: 2026) }

      it { is_expected.to be false }
    end

    context "when the academic_cycle is nil" do
      let(:allocation_subject) { instance_double(AllocationSubject, name: AllocationSubjects::PHYSICS) }
      let(:academic_cycle) { nil }

      it { is_expected.to be false }
    end
  end
end

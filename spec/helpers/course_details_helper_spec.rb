# frozen_string_literal: true

require "rails_helper"

describe CourseDetailsHelper do
  include CourseDetailsHelper

  describe "#course_subjects_options" do
    before do
      create(:subject_specialism, name: CourseSubjects::TRAVEL_AND_TOURISM)
      create(:subject_specialism, name: CourseSubjects::EARLY_YEARS_TEACHING)
    end

    it "iterates over CourseSubjects and prints out correct course_subjects values" do
      expect(course_subjects_options.size).to be 2
      expect(course_subjects_options.first.value).to be_nil
      expect(course_subjects_options.second.value).to eq CourseSubjects::TRAVEL_AND_TOURISM
    end
  end

  describe "#main_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :main, level: :primary).and_return(%w[main_age_range])
    end

    it "iterates over array and prints out correct main_age_ranges values" do
      expect(main_age_ranges_options).to contain_exactly "main_age_range"
    end
  end

  describe "#additional_age_ranges_options" do
    before do
      allow(self).to receive(:age_ranges).with(option: :additional, level: :primary).and_return(%w[additional_age_range])
    end

    it "iterates over array and prints out correct additional_age_ranges values" do
      expect(additional_age_ranges_options.size).to be 2
      expect(additional_age_ranges_options.first.value).to be_nil
      expect(additional_age_ranges_options.second.value).to eq "additional_age_range"
    end
  end

  describe "#subjects_for_summary_view" do
    let(:subject_one) { "Biology" }
    let(:subject_two) { "" }
    let(:subject_three) { "" }

    subject { subjects_for_summary_view(subject_one, subject_two, subject_three) }

    it { is_expected.to eq("Biology") }

    context "with primary education phase subjects" do
      let(:subject_one) { CourseSubjects::PRIMARY_TEACHING }

      it { is_expected.to eq(PublishSubjects::PRIMARY) }

      context "with multiple subjects" do
        let(:subject_two) { CourseSubjects::MODERN_LANGUAGES }

        it { is_expected.to eq(PublishSubjects::PRIMARY_WITH_MODERN_LANGUAGES) }
      end

      context "when primary with other is chosen" do
        let(:subject_two) { "Art and design" }
        let(:subject_three) { "Mathematics" }

        it { is_expected.to eq("Primary with Art and design and Mathematics") }
      end
    end

    context "with lowercased first subject" do
      let(:subject_one) { "applied biology" }

      it { is_expected.to eq("Applied biology") }
    end

    context "with two subjects" do
      let(:subject_two) { "Art and design" }

      it { is_expected.to eq("Biology with Art and design") }
    end

    context "without a second subject" do
      let(:subject_three) { "Mathematics" }

      it { is_expected.to eq("Biology with Mathematics") }
    end

    context "with three subjects" do
      let(:subject_two) { "Art and design" }
      let(:subject_three) { "Mathematics" }

      it { is_expected.to eq("Biology with Art and design and Mathematics") }
    end
  end

  describe "#start_year_options" do
    before do
      create(:academic_cycle, cycle_year: 2019)
      cycle_with_trainee = create(:academic_cycle, cycle_year: 2020)
      create(:academic_cycle, cycle_year: 2021)
      create(:trainee, commencement_date: Date.new(2021, 1, 2))
      allow(self).to receive(:academic_years_with_an_in_scope_trainee).and_return([cycle_with_trainee])
    end

    it "returns formatted start years where for which there is a trainee" do
      Timecop.freeze(Time.zone.local(2021, 1, 3)) do
        expect(filter_start_year_options.size).to eq(2)
        expect(filter_start_year_options.first.value).to eq("All years")
        expect(filter_start_year_options.last.value).to eq("2020 to 2021 (current year)")
      end
    end
  end
end

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
    let(:current_user) { double }

    before do
      allow(self).to receive(:request).and_return(double(path: "/trainees"))
    end

    it "returns formatted start years" do
      expect(AcademicYearFilterOptions).to receive(:new).with(user: current_user, draft: false)
                                                           .and_return(double(formatted_years: ["2020 to 2021"]))

      expect(filter_year_options(current_user, :start_year).map(&:value)).to eq(["All years", "2020 to 2021"])
    end
  end

  describe "#provider_options" do
    let(:providers) { build_list(:provider, 3) }

    it "returns a list of provider options" do
      expect(provider_options(providers).map(&:first)).to eql(providers.map(&:name_and_code))
      expect(provider_options(providers).map(&:second)).to eql(providers.map(&:id))
    end

    it "includes synonyms for the provider codes and UKPRN" do
      provider_options(providers).map(&:last).each_with_index do |option, index|
        expect(option[:"data-synonyms"]).to include(providers[index].ukprn)
        expect(option[:"data-synonyms"]).to include(providers[index].code)
      end
    end

    it "includes the UKPRN in the dropdown" do
      provider_options(providers).map(&:last).each_with_index do |option, index|
        expect(option[:"data-append"]).to include(providers[index].ukprn)
      end
    end
  end
end

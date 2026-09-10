# frozen_string_literal: true

require "rails_helper"

describe SubjectSpecialism do
  subject { create(:subject_specialism) }

  describe "associations" do
    it { is_expected.to belong_to(:allocation_subject) }
  end

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  describe ".secondary" do
    subject { described_class.secondary }

    let!(:secondary_specialism) { create(:subject_specialism, name: CourseSubjects::PRODUCT_DESIGN) }

    before do
      create(:subject_specialism, name: CourseSubjects::EARLY_YEARS_TEACHING)
      create(:subject_specialism, name: CourseSubjects::PRIMARY_TEACHING)
    end

    it { is_expected.to contain_exactly(secondary_specialism) }
  end

  describe "Electronics under Design and technology" do
    let!(:allocation_subject) { create(:allocation_subject, name: AllocationSubjects::DESIGN_AND_TECHNOLOGY) }
    let!(:electronics) do
      create(:subject_specialism, name: CourseSubjects::ELECTRONICS, allocation_subject:)
    end

    it "belongs to the Design and technology allocation subject" do
      expect(electronics.allocation_subject.name).to eq(AllocationSubjects::DESIGN_AND_TECHNOLOGY)
    end
  end
end

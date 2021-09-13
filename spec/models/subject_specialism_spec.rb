# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubjectSpecialism, type: :model do
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
      create(:subject_specialism, name: CourseSubjects::SPECIALIST_TEACHING_PRIMARY_WITH_MATHEMETICS)
    end

    it { is_expected.to match_array([secondary_specialism]) }
  end
end

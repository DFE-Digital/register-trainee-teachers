# frozen_string_literal: true

require "rails_helper"

describe Course do
  context "fields" do
    subject { create(:course) }

    it "validates presence" do
      expect(subject).to validate_presence_of(:code)
      expect(subject).to validate_presence_of(:name)
      expect(subject).to validate_presence_of(:start_date)
      expect(subject).to validate_presence_of(:level)
      expect(subject).to validate_presence_of(:age_range)
      expect(subject).to validate_presence_of(:duration_in_years)
      expect(subject).to validate_presence_of(:qualification)
      expect(subject).to validate_presence_of(:course_length)
    end

    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:provider_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:subjects) }
  end
end

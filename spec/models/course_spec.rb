# frozen_string_literal: true

require "rails_helper"

describe Course do
  context "fields" do
    subject { create(:course) }

    it do
      expect(subject).to define_enum_for(:level)
        .with_values({
          primary: 0,
          secondary: 1,
        })
    end

    it do
      expect(subject).to define_enum_for(:qualification)
        .with_values({
          qts: 0,
          pgce_with_qts: 1,
          pgde_with_qts: 2,
          pgce: 3,
          pgde: 4,
        })
    end

    it do
      expect(subject).to define_enum_for(:route)
        .with_values({
          TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
          TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => 3,
          TRAINING_ROUTE_ENUMS[:school_direct_salaried] => 4,
          TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => 5,
        })
    end

    it "validates presence" do
      expect(subject).to validate_presence_of(:code)
      expect(subject).to validate_presence_of(:name)
      expect(subject).to validate_presence_of(:start_date)
      expect(subject).to validate_presence_of(:level)
      expect(subject).to validate_presence_of(:min_age)
      expect(subject).to validate_presence_of(:max_age)
      expect(subject).to validate_presence_of(:duration_in_years)
      expect(subject).to validate_presence_of(:qualification)
      expect(subject).to validate_presence_of(:route)
    end

    it { is_expected.to validate_uniqueness_of(:code) }
  end

  describe "associations" do
    it { is_expected.to have_many(:subjects) }
  end

  describe ".end_date" do
    it "returns nil if start_date not set" do
      course = build(:course, start_date: nil)
      expect(course.end_date).to be_nil
    end

    it "returns nil if duration_in_years not set" do
      course = build(:course, start_date: Time.zone.today, duration_in_years: nil)
      expect(course.end_date).to be_nil
    end

    it "duration 1 year" do
      course = build(:course, start_date: Time.zone.today, duration_in_years: 1)
      expect(course.end_date).to eql(1.year.from_now.to_date.prev_day)
    end

    it "duration 2 years" do
      course = build(:course, start_date: Time.zone.today, duration_in_years: 2)
      expect(course.end_date).to eql(2.years.from_now.to_date.prev_day)
    end
  end
end

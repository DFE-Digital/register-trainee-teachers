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
          qts_with_undergraduate_degree: 5,
        })
    end

    it do
      expect(subject).to define_enum_for(:route)
        .with_values({
          TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
          TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] => 3,
          TRAINING_ROUTE_ENUMS[:school_direct_salaried] => 4,
          TRAINING_ROUTE_ENUMS[:pg_teaching_apprenticeship] => 5,
          TRAINING_ROUTE_ENUMS[:provider_led_undergrad] => 9,
          TRAINING_ROUTE_ENUMS[:teacher_degree_apprenticeship] => 14,
        })
    end

    it "validates presence" do
      expect(subject).to validate_presence_of(:code)
      expect(subject).to validate_presence_of(:name)
      expect(subject).to validate_presence_of(:published_start_date)
      expect(subject).to validate_presence_of(:level)
      expect(subject).to validate_presence_of(:duration_in_years)
      expect(subject).to validate_presence_of(:qualification)
      expect(subject).to validate_presence_of(:route)
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:subjects) }
  end

  describe "start/end dates" do
    let(:date_today) { Time.zone.today }
    let(:date_tomorrow) { date_today + 1.day }
    let(:course) { build(:course, study_mode: nil) }

    it "returns nil if study_mode not set" do
      expect(course.start_date).to be_nil
      expect(course.end_date).to be_nil
    end

    context "study_mode is part_time and course has part time dates" do
      let(:course) do
        build(:course, study_mode: :part_time, part_time_start_date: date_today, part_time_end_date: date_tomorrow)
      end

      it "can compute part time start and end dates" do
        expect(course.start_date).to eq(date_today)
        expect(course.end_date).to eq(date_tomorrow)
      end
    end
  end
end

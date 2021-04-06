# frozen_string_literal: true

require "rails_helper"

describe Course do
  context "fields" do
    subject { create(:course) }

    it do
      is_expected.to define_enum_for(:level)
        .with_values({
          primary: 0,
          secondary: 1,
        })
    end

    it do
      is_expected.to define_enum_for(:qualification)
        .with_values({
          qts: 0,
          pgce_with_qts: 1,
          pgde_with_qts: 2,
          pgce: 3,
          pgde: 4,
        })
    end

    it do
      is_expected.to define_enum_for(:age_range)
        .with_values({
          AgeRange::THREE_TO_SEVEN_COURSE => 0,
          AgeRange::THREE_TO_ELEVEN_COURSE => 1,
          AgeRange::FIVE_TO_ELEVEN_COURSE => 2,
          AgeRange::SEVEN_TO_ELEVEN_COURSE => 3,
          AgeRange::SEVEN_TO_FOURTEEN_COURSE => 4,
          AgeRange::ELEVEN_TO_SIXTEEN_COURSE => 5,
          AgeRange::ELEVEN_TO_NINETEEN_COURSE => 6,
          AgeRange::FOURTEEN_TO_NINETEEN_COURSE => 7,
          AgeRange::FOURTEEN_TO_NINETEEN_COURSE => 8,
        })
    end

    it do
      is_expected.to define_enum_for(:route)
        .with_values({
          TRAINING_ROUTE_ENUMS[:assessment_only] => 0,
          TRAINING_ROUTE_ENUMS[:provider_led_postgrad] => 1,
          TRAINING_ROUTE_ENUMS[:early_years_undergrad] => 2,
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
      expect(subject).to validate_presence_of(:age_range)
      expect(subject).to validate_presence_of(:duration_in_years)
      expect(subject).to validate_presence_of(:qualification)
      expect(subject).to validate_presence_of(:course_length)
      expect(subject).to validate_presence_of(:route)
    end

    it { is_expected.to validate_uniqueness_of(:code).scoped_to(:provider_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:subjects) }
  end
end

# frozen_string_literal: true

require "rails_helper"

describe Api::CreateTrainee do
  let(:current_provider) { create(:provider) }
  let(:trainee_attributes) { Api::V10Pre::TraineeAttributes.new }
  let(:version) { Settings.api.current_version }

  subject(:result) do
    described_class.call(
      current_provider:,
      trainee_attributes:,
      version:,
    )
  end

  describe "presence" do
    it "outputs the correct error messages" do
      expect(result[:status]).to eq(:unprocessable_entity)
      expect(result[:json][:errors]).to be_present

      (Api::V01::TraineeAttributes::REQUIRED_ATTRIBUTES + [:email]).each do |attribute|
        expect(result[:json][:errors]).to include("#{attribute} can't be blank")
      end
    end

    describe "email length" do
      before do
        trainee_attributes.email = "#{'a' * 256}@example.com"
      end

      it "outputs the correct error message" do
        expect(result[:json][:errors]).to include("Email is too long (maximum is 255 characters)")
      end
    end

    describe "inclusion" do
      let(:inclusion_attributes) do
        %i[
          ethnicity
          sex
          training_route
          course_subject_one
          course_subject_two
          course_subject_three
          study_mode
          nationality
          training_initiative
          nationality
        ].freeze
      end

      it "outputs the correct error messages" do
        inclusion_attributes.each do |attribute|
          trainee_attributes.send("#{attribute}=", "invalid_value")
        end
        inclusion_attributes.each do |attribute|
          expect(result[:json][:errors]).to include("#{attribute} has invalid reference data values")
        end
      end
    end
  end
end

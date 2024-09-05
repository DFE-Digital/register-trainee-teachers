# frozen_string_literal: true

require "rails_helper"

module Trainees
  describe FindDuplicatesOfHesaTrainee do
    let!(:current_academic_cycle) { create(:academic_cycle) }
    let!(:next_academic_cycle) { create(:academic_cycle, next_cycle: true) }
    let!(:after_next_academic_cycle) { create(:academic_cycle, one_after_next_cycle: true) }

    let(:trainee_attributes) do
      {
        provider_trainee_id: "1234567",
        first_names: "Bob",
        last_name: "Roberts",
        date_of_birth: "1998-03-19",
        email: "bob@example.com",
        training_route: :provider_led_postgrad,
        start_academic_cycle: current_academic_cycle,
        itt_start_date: current_academic_cycle.start_date,
      }
    end

    let(:imported_trainee) do
      create(
        :trainee,
        trainee_attributes.merge(record_source: Trainee::HESA_COLLECTION_SOURCE),
      )
    end

    subject(:duplicate_trainees) { described_class.call(trainee: imported_trainee) }

    context "trainee already exists" do
      before { create(:trainee, trainee_attributes.merge(record_source: Trainee::MANUAL_SOURCE)) }

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists but first name and email both differ" do
      before do
        create(
          :trainee,
          trainee_attributes.merge(
            first_names: "Alice",
            email: "alice@example.com",
            record_source: Trainee::MANUAL_SOURCE,
          ),
        )
      end

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with match last name and DOB exists and first name also matches but email differs" do
      before do
        create(
          :trainee,
          trainee_attributes.merge(
            email: "alice@example.com",
            record_source: Trainee::MANUAL_SOURCE,
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists and first name matches but email and middle names do not" do
      before do
        create(
          :trainee,
          trainee_attributes.merge(
            first_names: "Bob Norman",
            email: "alice@example.com",
            record_source: Trainee::MANUAL_SOURCE,
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with match last name and DOB exists but first name and email differ only by case/spacing" do
      before do
        create(
          :trainee,
          trainee_attributes.merge(
            first_names: " bOB.",
            email: "alice@example.com",
            record_source: Trainee::MANUAL_SOURCE,
          ),
        )
      end

      it "returns a match" do
        expect(duplicate_trainees).to be_present
      end
    end

    context "trainee with matching DOB exists but last name differs" do
      before { create(:trainee, trainee_attributes.merge(last_name: "Jones")) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name exists but DOB differs" do
      before { create(:trainee, trainee_attributes.merge(date_of_birth: "1998-04-19")) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name and DOB exists but qualification type differs" do
      before { create(:trainee, trainee_attributes.merge(training_route: :early_years_undergrad)) }

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end

    context "trainee with matching last_name and DOB exists but recruitment_cycle_year differs" do
      around do |example|
        Timecop.freeze(Date.new(2023, 7, 1)) { example.run }
      end

      before do
        previous_academic_cycle = create(:academic_cycle, previous_cycle: true)
        create(
          :trainee,
          trainee_attributes.merge(
            start_academic_cycle: previous_academic_cycle,
            itt_start_date: previous_academic_cycle.start_date,
          ),
        )
      end

      it "returns no duplicates" do
        expect(duplicate_trainees).to be_empty
      end
    end
  end
end

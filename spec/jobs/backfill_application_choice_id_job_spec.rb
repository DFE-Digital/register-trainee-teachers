# frozen_string_literal: true

require "rails_helper"

describe BackfillApplicationChoiceIdJob do
  describe "importing from HESA" do
    it "backfills application_choice_id from HESA student records" do
      trainee = create(
        :trainee,
        :imported_from_hesa,
        hesa_student_application_choice_id: 123456,
      )
      described_class.perform_now

      expect(trainee.reload.application_choice_id).to eq(123456)
    end

    it "does not write application_choice_id from HESA student records that don't have an application_choice_id" do
      trainee = create(
        :trainee,
        :imported_from_hesa,
      )
      described_class.perform_now

      expect(trainee.reload.application_choice_id).to be_nil
    end

    it "does not overwrite application_choice_id for a trainee that already has an application_choice_id" do
      trainee = create(
        :trainee,
        :imported_from_hesa,
        application_choice_id: 654321,
        hesa_student_application_choice_id: 123456,
      )
      described_class.perform_now

      expect(trainee.reload.application_choice_id).to eq(654321)
    end
  end

  describe "importing from Apply" do
    it "writes application_choice_id from apply application" do
      trainee = create(:trainee, :with_apply_application)
      trainee.apply_application.update!(apply_id: 123456)
      described_class.perform_now

      expect(trainee.reload.application_choice_id).to eq(123456)
    end

    it "does not write application_choice_id from apply application that has not have an apply_id" do
      trainee = create(:trainee, :with_apply_application, application_choice_id: 654321)
      trainee.apply_application.update!(apply_id: 123456)
      described_class.perform_now

      expect(trainee.reload.application_choice_id).to eq(654321)
    end
  end
end

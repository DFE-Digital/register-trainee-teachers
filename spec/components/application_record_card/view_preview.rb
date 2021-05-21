# frozen_string_literal: true

module ApplicationRecordCard
  class ViewPreview < ViewComponent::Preview
    def single_card
      render(ApplicationRecordCard::View.new(record: mock_trainee))
    end

    def multiple_cards
      render(ApplicationRecordCard::View.with_collection(mock_multiple_trainees))
    end

    def single_card_with_incomplete_data
      render(ApplicationRecordCard::View.new(record: Trainee.new(id: 1, created_at: Time.zone.now)))
    end

    def single_card_with_two_subjects
      render(ApplicationRecordCard::View.new(record: mock_trainee_with_two_subjects))
    end

    def single_card_with_three_subjects
      render(ApplicationRecordCard::View.new(record: mock_trainee_with_three_subjects))
    end

  private

    def mock_trainee
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        subject: "Primary",
      )
    end

    def mock_trainee_with_two_subjects
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        subject: "Primary",
        subject_two: "Science",
      )
    end

    def mock_trainee_with_three_subjects
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        subject: "Primary",
        subject_two: "Science",
        subject_three: "Mathematics",
      )
    end

    def mock_multiple_trainees
      [
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tom", last_name: "Jones", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], subject: "Primary", subject_two: "Mathematics", subject_three: "Latin"),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Paddington", last_name: "Bear", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], subject: "Science", subject_two: "Mathematics"),
        Trainee.new(id: 1, created_at: Time.zone.now),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tim", last_name: "Knight", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], subject: "Maths"),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Toby", last_name: "Rocker"),
      ]
    end
  end
end

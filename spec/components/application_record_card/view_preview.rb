# frozen_string_literal: true

module ApplicationRecordCard
  class ViewPreview < ViewComponent::Preview
    [true, false].each do |system_admin|
      suffice = system_admin ? "_as_system_admin" : ""
      define_method "single_card#{suffice}" do
        render(ApplicationRecordCard::View.new(record: mock_trainee, system_admin: system_admin))
      end

      define_method "multiple_cards#{suffice}" do
        render(ApplicationRecordCard::View.with_collection(mock_multiple_trainees, system_admin: system_admin))
      end

      define_method "single_card_with_incomplete_data#{suffice}" do
        render(ApplicationRecordCard::View.new(record: Trainee.new(id: 1, created_at: Time.zone.now, provider: mock_provider), system_admin: system_admin))
      end

      define_method "single_card_with_two_subjects#{suffice}" do
        render(ApplicationRecordCard::View.new(record: mock_trainee_with_two_subjects, system_admin: system_admin))
      end

      define_method "single_card_with_three_subjects#{suffice}" do
        render(ApplicationRecordCard::View.new(record: mock_trainee_with_three_subjects, system_admin: system_admin))
      end
    end

  private

    def mock_trainee
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        course_subject_one: "Primary",
        provider: mock_provider,
      )
    end

    def mock_trainee_with_two_subjects
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        course_subject_one: "Primary",
        course_subject_two: "Science",
        provider: mock_provider,
      )
    end

    def mock_trainee_with_three_subjects
      Trainee.new(
        id: 1,
        created_at: Time.zone.now,
        first_names: "Tom",
        last_name: "Jones",
        training_route: TRAINING_ROUTE_ENUMS[:assessment_only],
        course_subject_one: "Primary",
        course_subject_two: "Science",
        course_subject_three: "Mathematics",
        provider: mock_provider,
      )
    end

    def mock_multiple_trainees
      [
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tom", last_name: "Jones", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], course_subject_one: "Primary", course_subject_two: "Mathematics", course_subject_three: "Latin", provider: mock_provider),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Paddington", last_name: "Bear", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], course_subject_one: "Science", course_subject_two: "Mathematics", provider: mock_provider),
        Trainee.new(id: 1, created_at: Time.zone.now, provider: mock_provider),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Tim", last_name: "Knight", training_route: TRAINING_ROUTE_ENUMS[:assessment_only], course_subject_one: "Maths", provider: mock_provider),
        Trainee.new(id: 1, created_at: Time.zone.now, first_names: "Toby", last_name: "Rocker", provider: mock_provider),
      ]
    end

    def mock_provider
      Provider.new(code: "B1T", name: "DfE University")
    end
  end
end

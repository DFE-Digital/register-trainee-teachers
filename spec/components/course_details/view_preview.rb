# frozen_string_literal: true

require "govuk/components"

module CourseDetails
  class ViewPreview < ViewComponent::Preview
    %i[assessment_only
       early_years_undergrad
       pg_teaching_apprenticeship].each do |training_route_enums_key|
      define_method "#{training_route_enums_key}_default" do
        render(View.new(data_model: mock_trainee(training_route_enums_key:)))
      end

      define_method "#{training_route_enums_key}_with_no_data" do
        render(View.new(data_model: mock_trainee_with_no_data(training_route_enums_key:)))
      end

      define_method "#{training_route_enums_key}_with_multiple_subjects" do
        render(View.new(data_model: mock_trainee_with_multiple_subjects(training_route_enums_key:)))
      end
    end

  private

    def mock_trainee_with_no_data(training_route_enums_key:)
      @mock_trainee ||= Trainee.new(
        id: 1,
        provider: Provider.new,
        training_route: ReferenceData::TRAINING_ROUTES.find(training_route_enums_key).name,
      )
    end

    def mock_trainee(training_route_enums_key:)
      @mock_trainee ||= Trainee.new(
        id: 1,
        provider: Provider.new,
        course_subject_one: "Primary",
        course_age_range: [3, 11],
        itt_start_date: Date.new(2020, 1, 28),
        training_route: ReferenceData::TRAINING_ROUTES.find(training_route_enums_key).name,
      )
    end

    def mock_trainee_with_multiple_subjects(training_route_enums_key:)
      Trainee.new(
        id: 1,
        provider: Provider.new,
        course_subject_one: "Primary",
        course_subject_two: "Science",
        course_age_range: [3, 11],
        itt_start_date: Date.new(2020, 1, 28),
        training_route: ReferenceData::TRAINING_ROUTES.find(training_route_enums_key).name,
      )
    end
  end
end

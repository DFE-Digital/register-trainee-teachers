# frozen_string_literal: true

require "govuk/components"

module Schools
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(data_model: mock_trainee))
    end

    def with_employing_school
      render(View.new(data_model: mock_trainee(with_employing_school: true, route: ReferenceData::TRAINING_ROUTES.school_direct_salaried.name)))
    end

    def with_no_data
      render(View.new(data_model: Trainee.new(id: 2, training_route: ReferenceData::TRAINING_ROUTES.assessment_only.name)))
    end

  private

    def mock_trainee(with_employing_school: false, route: ReferenceData::TRAINING_ROUTES.school_direct_tuition_fee.name)
      Trainee.new(
        id: 1,
        course_subject_one: "Primary",
        course_age_range: [3, 11],
        itt_start_date: Date.new(2020, 0o1, 28),
        training_route: route,
        lead_partner_school: mock_school,
        employing_school: with_employing_school ? mock_school : nil,
      )
    end

    def mock_school
      @mock_school ||= School.new(
        id: 1,
        urn: "12345",
        name: "Test School",
        postcode: "E1 5DJ",
        town: "London",
        open_date: Time.zone.today,
      )
    end
  end
end

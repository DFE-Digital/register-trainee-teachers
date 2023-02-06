# frozen_string_literal: true

require "govuk/components"

module DqtDataSummary
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(dqt_data: mock_dqt_data))
    end

  private

    def mock_dqt_data
      {
        "trn" => "1234567",
        "ni_number" => nil,
        "qualified_teacher_status" => {
          "name" => "Trainee Teacher",
          "state" => "Active",
          "state_name" => "Active",
          "qts_date" => "2022-09-19",
        },
        "induction" => {
          "start_date" => "2023-09-19T00:00:00Z",
          "completion_date" => nil,
          "status" => nil,
          "state" => "Active",
          "state_name" => nil,
        },
        "initial_teacher_training" => {
          "state" => "Active",
          "state_code" => "Active",
          "programme_start_date" => "2022-09-19T00:00:00Z",
          "programme_end_date" => "2026-05-22T00:00:00Z",
          "programme_type" => "Provider-led (undergrad)",
          "result" => "In Training",
          "subject1" => "primary teaching",
          "subject2" => nil,
          "subject3" => nil,
          "qualification" => "BA (Hons)",
          "subject1_code" => "100511",
          "subject2_code" => nil,
          "subject3_code" => nil,
        },
        "qualifications" => [
          {
            "name" => "Higher Education",
            "date_awarded" => nil,
            "he_qualification_name" => "First Degree",
            "he_subject1" => nil,
            "he_subject2" => nil,
            "he_subject3" => nil,
            "he_subject1_code" => nil,
            "he_subject2_code" => nil,
            "he_subject3_code" => nil,
            "class" => nil,
          },
        ],
        "name" => "Abigail McPhillips",
        "dob" => "1990-04-27T00:00:00",
        "active_alert" => false,
        "state" => "Active",
        "state_name" => "Active",
      }
    end
  end
end

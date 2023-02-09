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
        "trn" => "0123456",
        "firstName" => "Abigail",
        "lastName" => "McPhillips",
        "dateOfBirth" => "1991-07-04",
        "qtsDate" => nil,
        "eytsDate" => "2022-07-07",
        "initialTeacherTraining" => [
          {
            "programmeStartDate" => "2021-09-07",
            "programmeEndDate" => "2022-07-29",
            "programmeType" => "EYITTGraduateEntry",
            "result" => "Pass",
            "provider" => { "ukprn" => "10005790" },
          },
          {
            "programmeStartDate" => "2020-09-07",
            "programmeEndDate" => "2021-07-29",
            "programmeType" => "ProviderLed",
            "result" => "Withdrawn",
            "provider" => { "ukprn" => "10005790" },
          },
        ],
      }
    end
  end
end

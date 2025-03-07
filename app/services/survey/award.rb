# frozen_string_literal: true

module Survey
  # Service for sending QTS award surveys to trainees
  # This class handles the specific implementation details for award surveys
  class Award < Base
    include ServicePattern
    
    delegate :awarded_at, to: :trainee

    private

    def survey_id
      Settings.qualtrics.award.survey_id
    end

    def mailing_list_id
      Settings.qualtrics.award.mailing_list_id
    end

    def message_id
      Settings.qualtrics.award.message_id
    end

    def subject
      "QTS Award Survey"
    end

    def embedded_data_for_contact
      {
        "award_date" => awarded_at,
        "training_route" => training_route,
      }
    end

    def embedded_data_for_distribution
      {
        award_date: awarded_at,
        training_route: training_route,
      }
    end
  end
end 
# frozen_string_literal: true

module Survey
  # Service for sending QTS award surveys to trainees
  class Award < Base
    delegate :awarded_at, to: :trainee

  private

    def should_send_survey?
      trainee.awarded_at.present? && trainee.awarded?
    end

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

    def embedded_data_for_distribution
      {
        award_date: awarded_at,
        training_route: training_route,
      }
    end

    def embedded_data_for_contact
      embedded_data_for_distribution.stringify_keys
    end
  end
end

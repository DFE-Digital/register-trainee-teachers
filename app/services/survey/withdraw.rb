# frozen_string_literal: true

module Survey
  # Service for sending withdrawal surveys to trainees
  class Withdraw < Base
    delegate :withdraw_date, to: :trainee

  private

    def survey_id
      Settings.qualtrics.withdraw.survey_id
    end

    def mailing_list_id
      Settings.qualtrics.withdraw.mailing_list_id
    end

    def message_id
      Settings.qualtrics.withdraw.message_id
    end

    def subject
      "Teacher Training Withdrawal Survey"
    end

    def embedded_data_for_contact
      {
        "withdraw_date" => withdraw_date,
        "training_route" => training_route,
      }
    end

    def embedded_data_for_distribution
      {
        withdraw_date:,
        training_route:,
      }
    end
  end
end

# frozen_string_literal: true

module Survey
  # Base class for survey services that handles common functionality for
  # creating contacts in Qualtrics mailing lists and sending survey distributions.
  #
  # Subclasses must implement:
  # - survey_id: The ID of the survey in Qualtrics
  # - mailing_list_id: The ID of the mailing list in Qualtrics
  # - message_id: The ID of the message template in Qualtrics
  # - subject: The subject line for the email
  # - embedded_data_for_contact: The data to embed in the contact
  # - embedded_data_for_distribution: The data to embed in the distribution
  # - should_send_survey?: Check if the survey should be sent based on trainee state
  #
  # Subclasses may override:
  # - from_name: The name to display in the from field (defaults to "Teacher Training Support")
  class Base
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      return false unless should_send_survey?

      unless response.success?
        raise(StandardError, response.body)
      end

      true
    end

  private

    attr_reader :trainee

    delegate :first_names, :last_name, :email, :training_route, to: :trainee

    def response
      @response ||= create_distribution
    end

    def contact_id
      @contact_id ||= begin
        response_body = create_contact_in_mailing_list_response.body
        JSON.parse(response_body)["result"]["contactLookupId"]
      end
    end

    def create_contact_in_mailing_list_response
      @create_contact_in_mailing_list_response ||= QualtricsApi::Client::Request.post(
        "/directories/#{directory_id}/mailinglists/#{mailing_list_id}/contacts",
        body: create_contact_in_mailing_list_body,
      )
    end

    def create_contact_in_mailing_list_body
      {
        "email" => email,
        "firstName" => first_names,
        "lastName" => last_name,
        embeddedData: embedded_data_for_contact,
      }.to_json
    end

    def create_distribution
      QualtricsApi::Client::Request.post(
        "/distributions",
        body: create_distribution_body,
      )
    end

    def create_distribution_body
      {
        message: {
          libraryId: library_id,
          messageId: message_id,
        },
        recipients: {
          mailingListId: mailing_list_id,
          contactId: contact_id,
        },
        header: {
          fromEmail: Settings.data_email,
          fromName: from_name,
          subject: subject,
          replyToEmail: Settings.data_email,
        },
        surveyLink: {
          surveyId: survey_id,
          expirationDate: expiration_date,
          type: "Individual",
        },
        sendDate: send_date,
        embeddedData: embedded_data_for_distribution,
      }.to_json
    end

    def send_date
      Settings.qualtrics.minutes_delayed.minutes.from_now.utc.iso8601
    end

    def expiration_date
      Settings.qualtrics.days_delayed.days.from_now.utc.iso8601
    end

    def directory_id
      Settings.qualtrics.directory_id
    end

    def library_id
      Settings.qualtrics.library_id
    end

    def from_name
      "Teacher Training Support"
    end

    # Methods that subclasses must implement
    def should_send_survey?
      raise(NotImplementedError, "Subclasses must implement should_send_survey?")
    end

    def survey_id
      raise(NotImplementedError, "Subclasses must implement survey_id")
    end

    def mailing_list_id
      raise(NotImplementedError, "Subclasses must implement mailing_list_id")
    end

    def message_id
      raise(NotImplementedError, "Subclasses must implement message_id")
    end

    def subject
      raise(NotImplementedError, "Subclasses must implement subject")
    end

    def embedded_data_for_contact
      raise(NotImplementedError, "Subclasses must implement embedded_data_for_contact")
    end

    def embedded_data_for_distribution
      raise(NotImplementedError, "Subclasses must implement embedded_data_for_distribution")
    end
  end
end

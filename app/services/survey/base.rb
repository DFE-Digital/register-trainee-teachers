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
  #
  # Subclasses may override:
  # - from_name: The name to display in the from field (defaults to "Teacher Training Support")
  class Base
    def initialize(trainee:)
      @trainee = trainee
    end

    # Sends a survey to the trainee by:
    # 1. Creating a contact in the Qualtrics mailing list
    # 2. Creating a distribution to send the survey to the contact
    #
    # @return [Boolean] true if successful, false otherwise
    def call
      begin
        create_contact_in_mailing_list_body = create_contact_in_mailing_list_response.body
        contact_lookup_id = JSON.parse(create_contact_in_mailing_list_body)["result"]["contactLookupId"]
        response = create_distribution_response(contact_lookup_id)
        
        # Return true if successful
        response.status.success?
      rescue StandardError => e
        Rails.logger.error("Failed to send survey: #{e.message}")
        false
      end
    end

  private

    attr_reader :trainee

    delegate :first_names, :last_name, :email, :training_route, to: :trainee

    def create_contact_in_mailing_list_response
      @create_contact_in_mailing_list_response ||= QualtricsApi::Client::Request.post("/directories/#{directory_id}/mailinglists/#{mailing_list_id}/contacts", body: create_contact_in_mailing_list_body)
    end

    def create_contact_in_mailing_list_body
      {
        "email" => email,
        "firstName" => first_names,
        "lastName" => last_name,
        embeddedData: embedded_data_for_contact,
      }.to_json
    end

    def create_distribution_body(contact_lookup_id)
      {
        message: {
          libraryId: library_id,
          messageId: message_id,
        },
        recipients: {
          mailingListId: mailing_list_id,
          contactId: contact_lookup_id,
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

    def create_distribution_response(contact_lookup_id)
      @create_distribution_response ||= QualtricsApi::Client::Request.post("/distributions", body: create_distribution_body(contact_lookup_id))
    end

    def send_date
      5.minutes.from_now.utc.iso8601
    end

    def expiration_date
      5.days.from_now.utc.iso8601
    end

    def directory_id
      Settings.qualtrics.directory_id
    end

    def library_id
      Settings.qualtrics.library_id
    end

    # The ID of the survey in Qualtrics
    # @return [String]
    def survey_id
      raise NotImplementedError, "Subclasses must implement survey_id"
    end

    # The ID of the mailing list in Qualtrics
    # @return [String]
    def mailing_list_id
      raise NotImplementedError, "Subclasses must implement mailing_list_id"
    end

    # The ID of the message template in Qualtrics
    # @return [String]
    def message_id
      raise NotImplementedError, "Subclasses must implement message_id"
    end

    # The name to display in the from field
    # @return [String]
    def from_name
      "Teacher Training Support"
    end

    # The subject line for the email
    # @return [String]
    def subject
      raise NotImplementedError, "Subclasses must implement subject"
    end

    # The data to embed in the contact
    # @return [Hash]
    def embedded_data_for_contact
      raise NotImplementedError, "Subclasses must implement embedded_data_for_contact"
    end

    # The data to embed in the distribution
    # @return [Hash]
    def embedded_data_for_distribution
      raise NotImplementedError, "Subclasses must implement embedded_data_for_distribution"
    end
  end
end 
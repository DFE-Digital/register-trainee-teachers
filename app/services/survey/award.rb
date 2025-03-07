# frozen_string_literal: true

module Survey
  class Award
    include ServicePattern

    def initialize(trainee:)
      @trainee = trainee
    end

    def call
      create_contact_in_mailing_list_body = create_contact_in_mailing_list_response.body
      contact_lookup_id = JSON.parse(create_contact_in_mailing_list_body)["result"]["contactLookupId"]
      create_distribution_response(contact_lookup_id)
    end

  private

    attr_reader :trainee

    delegate :first_names, :last_name, :email, :awarded_at, :training_route, to: :trainee

    def create_contact_in_mailing_list_response
      @create_contact_in_mailing_list_response ||= QualtricsApi::Client::Request.post("/directories/#{directory_id}/mailinglists/#{mailing_list_id}/contacts", body: create_contact_in_mailing_list_body)
    end

    def create_contact_in_mailing_list_body
      {
        "email" => email,
        "firstName" => first_names,
        "lastName" => last_name,
        embeddedData: {
          "award_date" => awarded_at,
          "training_route" => training_route,
        },
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
          fromName: "Teacher Training Support",
          subject: "QTS Award Survey",
          replyToEmail: Settings.data_email,
        },
        surveyLink: {
          surveyId: survey_id,
          expirationDate: expiration_date,
          type: "Individual",
        },
        sendDate: send_date,
        embeddedData: {
          award_date: awarded_at,
          training_route: training_route,
        },
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

    def survey_id
      Settings.qualtrics.award.survey_id
    end

    def mailing_list_id
      Settings.qualtrics.award.mailing_list_id
    end

    def message_id
      Settings.qualtrics.award.message_id
    end

    def directory_id
      Settings.qualtrics.directory_id
    end

    def library_id
      Settings.qualtrics.library_id
    end
  end
end

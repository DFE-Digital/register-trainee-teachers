# frozen_string_literal: true

RSpec.shared_examples "a survey service" do |date_field, email_subject|
  let(:contact_response) do
    instance_double(HTTParty::Response,
                    body: { result: { contactLookupId: "CONTACT_ID_123" } }.to_json,
                    success?: true)
  end

  let(:distribution_response) do
    instance_double(HTTParty::Response,
                    body: { result: { distributionId: "DIST_123" } }.to_json,
                    success?: true)
  end

  it "creates a contact with the correct data" do
    allow(QualtricsApi::Client::Request).to receive(:post)
      .with(
        "/directories/FAKE_DIRECTORY_ID/mailinglists/FAKE_MAILING_LIST_ID/contacts",
        body: lambda { |body|
          json = JSON.parse(body)
          json["email"] == email &&
          json["firstName"] == first_names &&
          json["lastName"] == last_name &&
          json["embeddedData"].is_a?(Hash) &&
          json["embeddedData"]["training_route"] == training_route &&
          json["embeddedData"].key?(date_field.to_s)
        },
      )
      .and_return(contact_response)

    allow(QualtricsApi::Client::Request).to receive(:post)
      .with(
        "/distributions",
        body: kind_of(String),
      )
      .and_return(distribution_response)

    expect(subject).to be true

    expect(QualtricsApi::Client::Request).to have_received(:post)
      .with(
        "/directories/FAKE_DIRECTORY_ID/mailinglists/FAKE_MAILING_LIST_ID/contacts",
        body: kind_of(String),
      )
  end

  it "sends a distribution with the correct data" do
    allow(QualtricsApi::Client::Request).to receive(:post)
      .with(
        "/directories/FAKE_DIRECTORY_ID/mailinglists/FAKE_MAILING_LIST_ID/contacts",
        body: kind_of(String),
      )
      .and_return(contact_response)

    allow(QualtricsApi::Client::Request).to receive(:post)
      .with(
        "/distributions",
        body: lambda { |body|
          json = JSON.parse(body)
          json["message"]["libraryId"] == "FAKE_LIBRARY_ID" &&
          json["message"]["messageId"] == "FAKE_MESSAGE_ID" &&
          json["recipients"]["mailingListId"] == "FAKE_MAILING_LIST_ID" &&
          json["recipients"]["contactId"] == "CONTACT_ID_123" &&
          json["header"]["subject"] == email_subject &&
          json["surveyLink"]["surveyId"] == "FAKE_SURVEY_ID" &&
          json["embeddedData"].is_a?(Hash) &&
          json["embeddedData"]["training_route"] == training_route &&
          json["embeddedData"].key?(date_field.to_s)
        },
      )
      .and_return(distribution_response)

    expect(subject).to be true

    expect(QualtricsApi::Client::Request).to have_received(:post)
      .with(
        "/distributions",
        body: kind_of(String),
      )
  end

  context "when the API call fails" do
    let(:failure_response) do
      instance_double(
        HTTParty::Response,
        code: 403,
        body: {
          meta: {
            httpStatus: "403 - Forbidden",
            error: { errorMessage: "Access denied to TA entity", errorCode: "TAG_0.4" },
          },
        }.to_json,
        success?: false,
        headers: {},
      )
    end

    before do
      allow(QualtricsApi::Client::Request).to receive(:post).and_return(failure_response)
    end

    it "raises an HttpError with the Qualtrics error details" do
      expect { subject }.to raise_error(
        QualtricsApi::Client::HttpError,
        /TAG_0\.4: Access denied to TA entity/,
      )
    end
  end
end

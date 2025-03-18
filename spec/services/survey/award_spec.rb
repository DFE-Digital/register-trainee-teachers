# frozen_string_literal: true

require "rails_helper"

module Survey
  describe Award do
    let(:first_names) { "Trentham" }
    let(:last_name) { "Fong" }
    let(:email) { "trentham.fong@example.com" }
    let(:awarded_at) { Time.zone.now.iso8601 }
    let(:training_route) { "provider_led_postgrad" }

    let(:trainee) do
      build(:trainee,
            first_names: first_names,
            last_name: last_name,
            email: email,
            awarded_at: awarded_at,
            training_route: training_route)
    end

    let(:settings_stub) do
      allow(Settings).to receive(:qualtrics).and_return(
        OpenStruct.new(
          api_token: "please_change_me",
          directory_id: "FAKE_DIRECTORY_ID",
          base_url: "https://fra1.qualtrics.com/API/v3/",
          library_id: "FAKE_LIBRARY_ID",
          award: OpenStruct.new(
            survey_id: "FAKE_SURVEY_ID",
            mailing_list_id: "FAKE_MAILING_LIST_ID",
            message_id: "FAKE_MESSAGE_ID"
          )
        )
      )
      allow(Settings).to receive(:data_email).and_return("registerateacher@education.gov.uk")
    end

    before do
      settings_stub
    end

    describe "#call" do
      subject { described_class.call(trainee: trainee) }

      it "creates a contact and sends a survey distribution" do
        # Stub the contact creation response
        contact_response = double(
          body: { result: { contactLookupId: "CONTACT_ID_123" } }.to_json
        )
        
        # Stub the distribution creation response
        distribution_response = double(
          body: { result: { distributionId: "DIST_123" } }.to_json
        )

        # Expect the contact creation request
        expect(QualtricsApi::Client::Request).to receive(:post)
          .with(
            "/directories/FAKE_DIRECTORY_ID/mailinglists/FAKE_MAILING_LIST_ID/contacts",
            body: kind_of(String)
          )
          .and_return(contact_response)

        # Expect the distribution creation request
        expect(QualtricsApi::Client::Request).to receive(:post)
          .with(
            "/distributions",
            body: kind_of(String)
          )
          .and_return(distribution_response)

        expect(subject).to be true
      end

      context "when the API call fails" do
        before do
          allow(QualtricsApi::Client::Request).to receive(:post)
            .and_raise(
              QualtricsApi::Client::HttpError,
              "status: 500, body: Internal Server Error"
            )
        end

        it "raises an HttpError" do
          expect { subject }.to raise_error(QualtricsApi::Client::HttpError)
        end
      end
    end
  end
end 
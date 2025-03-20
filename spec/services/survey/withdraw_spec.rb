# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/survey_service_examples"

module Survey
  describe Withdraw do
    let(:first_names) { "Trentham" }
    let(:last_name) { "Fong" }
    let(:email) { "trentham.fong@example.com" }
    let(:withdraw_date) { Time.zone.today }
    let(:training_route) { "provider_led_postgrad" }

    let(:trainee) do
      build(:trainee,
            first_names:,
            last_name:,
            email:,
            training_route:)
    end

    let(:withdrawn_trainee) do
      create(:trainee, :withdrawn,
             first_names:,
             last_name:,
             email:,
             training_route:)
    end

    let(:settings_stub) do
      allow(Settings).to receive_messages(qualtrics: OpenStruct.new(
        minutes_delayed: 5,
        days_delayed: 7,
        api_token: "please_change_me",
        directory_id: "FAKE_DIRECTORY_ID",
        base_url: "https://fra1.qualtrics.com/API/v3/",
        library_id: "FAKE_LIBRARY_ID",
        withdraw: OpenStruct.new(
          survey_id: "FAKE_SURVEY_ID",
          mailing_list_id: "FAKE_MAILING_LIST_ID",
          message_id: "FAKE_MESSAGE_ID",
        ),
      ), data_email: "registerateacher@education.gov.uk")
    end

    before do
      settings_stub
      allow(QualtricsApi::Client::Request).to receive(:post).and_return(
        instance_double(Response, body: { result: { contactLookupId: "contact-123" } }.to_json),
      )
    end

    describe "#call" do
      subject { described_class.call(trainee:) }

      it_behaves_like "a survey service", "withdraw_date", "Teacher Training Withdrawal Survey" do
        let(:trainee) { withdrawn_trainee }
      end

      context "when trainee is withdrawn" do
        it "sends the survey" do
          expect(QualtricsApi::Client::Request).to receive(:post).twice
          expect(described_class.call(trainee: withdrawn_trainee)).to be true
        end
      end

      context "when trainee is not withdrawn anymore" do
        let(:not_withdrawn_trainee) { create(:trainee, :trn_received) }

        it "does not send the survey" do
          expect(QualtricsApi::Client::Request).not_to receive(:post)
          expect(described_class.call(trainee: not_withdrawn_trainee)).to be false
        end
      end
    end
  end
end

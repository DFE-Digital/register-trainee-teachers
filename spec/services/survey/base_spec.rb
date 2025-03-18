# frozen_string_literal: true

require "rails_helper"

module Survey
  describe Base do
    # Subclass for testing
    class TestSurvey < Base
      def initialize(trainee:)
        super
      end

      private

      def survey_id
        "TEST_SURVEY_ID"
      end

      def mailing_list_id
        "TEST_MAILING_LIST_ID"
      end

      def message_id
        "TEST_MESSAGE_ID"
      end

      def subject
        "Test Survey"
      end

      def embedded_data_for_contact
        {
          "test_data" => "test_value",
          "training_route" => training_route
        }
      end

      def embedded_data_for_distribution
        {
          test_data: "test_value",
          training_route: training_route
        }
      end
    end

    let(:first_names) { "Trentham" }
    let(:last_name) { "Fong" }
    let(:email) { "trentham.fong@example.com" }
    let(:training_route) { "provider_led_postgrad" }

    let(:trainee) do
      build(:trainee,
            first_names: first_names,
            last_name: last_name,
            email: email,
            training_route: training_route)
    end

    let(:settings_stub) do
      allow(Settings).to receive(:data_email).and_return("registerateacher@education.gov.uk")
    end

    before do
      settings_stub
    end

    describe "#call" do
      subject { TestSurvey.call(trainee: trainee) }


      context "when required methods are not implemented in a subclass" do
        class InvalidSurvey < Base; end

        it "raises NotImplementedError for survey_id" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:survey_id) }.to raise_error(
            NotImplementedError, "Subclasses must implement survey_id"
          )
        end

        it "raises NotImplementedError for mailing_list_id" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:mailing_list_id) }.to raise_error(
            NotImplementedError, "Subclasses must implement mailing_list_id"
          )
        end

        it "raises NotImplementedError for message_id" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:message_id) }.to raise_error(
            NotImplementedError, "Subclasses must implement message_id"
          )
        end

        it "raises NotImplementedError for subject" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:subject) }.to raise_error(
            NotImplementedError, "Subclasses must implement subject"
          )
        end

        it "raises NotImplementedError for embedded_data_for_contact" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:embedded_data_for_contact) }.to raise_error(
            NotImplementedError, "Subclasses must implement embedded_data_for_contact"
          )
        end

        it "raises NotImplementedError for embedded_data_for_distribution" do
          expect { InvalidSurvey.send(:new, trainee: trainee).send(:embedded_data_for_distribution) }.to raise_error(
            NotImplementedError, "Subclasses must implement embedded_data_for_distribution"
          )
        end
      end
    end
  end
end 
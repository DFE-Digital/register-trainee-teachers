# frozen_string_literal: true

require "rails_helper"

module Survey
  describe Base do
    let(:first_names) { "Trentham" }
    let(:last_name) { "Fong" }
    let(:email) { "trentham.fong@example.com" }
    let(:training_route) { "provider_led_postgrad" }

    let(:trainee) do
      build(:trainee,
            first_names:,
            last_name:,
            email:,
            training_route:)
    end

    let(:settings_stub) do
      allow(Settings).to receive_messages(qualtrics: OpenStruct.new(
        api_token: "please_change_me",
        directory_id: "FAKE_DIRECTORY_ID",
        base_url: "https://fra1.qualtrics.com/API/v3/",
        library_id: "FAKE_LIBRARY_ID",
      ), data_email: "data@example.com")
    end

    before do
      settings_stub
    end

    # A simple test to verify the ServicePattern is being used
    it "includes ServicePattern" do
      expect(described_class.included_modules).to include(ServicePattern)
    end

    # A simple test to verify that the class has the expected behavior
    it "defines the required abstract methods" do
      required_methods = %i[
        survey_id
        mailing_list_id
        message_id
        subject
        embedded_data_for_contact
        embedded_data_for_distribution
      ]

      required_methods.each do |method_name|
        expect(described_class.instance_methods(false) + described_class.private_instance_methods(false)).to include(method_name)
      end
    end
  end
end

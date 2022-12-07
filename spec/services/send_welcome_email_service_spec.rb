# frozen_string_literal: true

require "rails_helper"

describe SendWelcomeEmailService do
  before do
    enable_features(:send_emails)
  end

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  after { Timecop.return }

  context "when the user has not logged in before" do
    context "lead school user" do
      let(:current_user) do
        spy(
          first_name: "Meowington",
          email: "meowington@cat.net",
          welcome_email_sent_at: nil,
          lead_schools: [build(:school, :lead)],
        )
      end

      before do
        allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
        described_class.call(current_user:)
      end

      it "sets their welcome email date to now" do
        expect(current_user).to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
      end

      it "sends the welcome email" do
        expect(WelcomeEmailMailer).to have_received(:generate)
      end

      it "sends the email to the user" do
        expect(WelcomeEmailMailer).to have_received(:generate).with(hash_including(email: "meowington@cat.net"))
      end

      it "sends the users first name in the email" do
        expect(WelcomeEmailMailer).to have_received(:generate).with(hash_including(first_name: "Meowington"))
      end
    end

    context "not a lead school user" do
      let(:current_user) do
        spy(
          first_name: "Meowington",
          email: "meowington@cat.net",
          welcome_email_sent_at: nil,
          lead_schools: [],
        )
      end

      before do
        described_class.call(current_user:)
      end

      it "does not update welcome_email_sent_at field" do
        expect(current_user).not_to have_received(:update!)
      end
    end
  end

  context "when a lead school user has logged in before" do
    let(:current_user) do
      spy(
        first_name: "Meowington",
        welcome_email_sent_at: Time.zone.local(2021, 1, 1),
        lead_schools: [build(:school, :lead)],
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
      described_class.call(current_user:)
    end

    context "and has received a welcome email" do
      it "does not update their welcome email date" do
        expect(current_user).not_to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
      end

      it "does not send the welcome email" do
        expect(WelcomeEmailMailer).not_to have_received(:generate)
      end
    end
  end
end

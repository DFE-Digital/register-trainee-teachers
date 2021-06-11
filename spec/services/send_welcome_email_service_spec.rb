# frozen_string_literal: true

require "rails_helper"

describe SendWelcomeEmailService do
  before do
    enable_features(:send_emails)
    Timecop.freeze
  end

  after { Timecop.return }

  context "when the user has not logged in before" do
    let(:current_user_spy) do
      spy(
        first_name: "Meowington",
        email: "meowington@cat.net",
        welcome_email_sent_at: nil,
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
      described_class.call(current_user: current_user_spy)
    end

    it "sets their welcome email date to now" do
      expect(current_user_spy).to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
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

  context "when the user has logged in before" do
    let(:current_user_spy) do
      spy(
        first_name: "Meowington",
        welcome_email_sent_at: Time.zone.local(2021, 1, 1),
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
      described_class.call(current_user: current_user_spy)
    end

    context "and has received a welcome email" do
      it "does not update their welcome email date" do
        expect(current_user_spy).not_to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
      end

      it "does not send the welcome email" do
        expect(WelcomeEmailMailer).not_to have_received(:generate)
      end
    end
  end
end

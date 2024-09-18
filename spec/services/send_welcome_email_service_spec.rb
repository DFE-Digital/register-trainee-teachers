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
    context "lead partner user" do
      let(:user) do
        spy(
          first_name: "Meowington",
          email: "meowington@cat.net",
          welcome_email_sent_at: nil,
          lead_partners: [build(:lead_partner)],
        )
      end

      before do
        allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
        described_class.call(user:)
      end

      it "sets their welcome email date to now" do
        expect(user).to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
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

    context "not a lead partner user" do
      let(:user) do
        spy(
          first_name: "Meowington",
          email: "meowington@cat.net",
          welcome_email_sent_at: nil,
          lead_partners: [],
        )
      end

      before do
        described_class.call(user:)
      end

      it "does not update welcome_email_sent_at field" do
        expect(user).not_to have_received(:update!)
      end
    end
  end

  context "when a lead partner user has logged in before" do
    let(:user) do
      spy(
        first_name: "Meowington",
        welcome_email_sent_at: Time.zone.local(2021, 1, 1),
        lead_partners: [build(:lead_partner)],
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
      described_class.call(user:)
    end

    context "and has received a welcome email" do
      it "does not update their welcome email date" do
        expect(user).not_to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
      end

      it "does not send the welcome email" do
        expect(WelcomeEmailMailer).not_to have_received(:generate)
      end
    end
  end

  context "when a partner user has logged in before" do
    let(:user) do
      spy(
        first_name: "Meowington",
        welcome_email_sent_at: Time.zone.local(2021, 1, 1),
        lead_partners: [build(:lead_partner, :school)],
      )
    end

    before do
      allow(WelcomeEmailMailer).to receive_message_chain(:generate, :deliver_later)
      described_class.call(user:)
    end

    context "and has received a welcome email" do
      it "does not update their welcome email date" do
        expect(user).not_to have_received(:update!).with(hash_including(welcome_email_sent_at: Time.zone.now))
      end

      it "does not send the welcome email" do
        expect(WelcomeEmailMailer).not_to have_received(:generate)
      end
    end
  end
end

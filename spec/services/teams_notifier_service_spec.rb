# frozen_string_literal: true

require "rails_helper"

describe TeamsNotifierService do
  let(:channel_webhook) { "https://example.com/teamswebhook" }
  let(:default_webhook) { "https://example.com/defaultteamswebhook" }
  let(:message) { "hello world" }
  let(:icon_emoji) { "&#x1F419;" }

  describe "#call" do
    context "when no webhook is passed" do
      before do
        allow(Settings.notifications.teams.webhooks).to receive(:register_support_channel).and_return(default_webhook)
        allow(TeamsWebhook::Client).to receive(:post)
      end

      it "sends a message using the default webhook" do
        expect(TeamsWebhook::Client).to receive(:post).with(
          default_webhook,
          body: { text: "#{icon_emoji} #{message}" }.to_json,
        )

        described_class.call(message:)
      end

      it "does not include icon when icon_emoji is nil" do
        expect(TeamsWebhook::Client).to receive(:post).with(
          default_webhook,
          body: { text: message }.to_json,
        )

        described_class.call(message:, icon_emoji: nil)
      end
    end

    context "when webhook is passed" do
      before do
        allow(TeamsWebhook::Client).to receive(:post)
      end

      it "sends a message using the passed webhook" do
        expect(TeamsWebhook::Client).to receive(:post).with(
          channel_webhook,
          body: { text: "#{icon_emoji} #{message}" }.to_json,
        )

        described_class.call(channel_webhook:, message:, icon_emoji:)
      end
    end
  end
end

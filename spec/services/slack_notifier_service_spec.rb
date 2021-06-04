# frozen_string_literal: true

require "rails_helper"

describe SlackNotifierService do
  let(:channel_webhook) { "https://example.com/captainwebhook" }
  let(:default_webhook) { "https://example.com/webhooklineandsinker" }
  let(:message) { "hello world" }
  let(:username) { "Test Username" }
  let(:icon_emoji) { ":inky-the-octopus:" }
  let(:slack_notifier) { instance_double(Slack::Notifier) }

  describe "#call" do
    context "when no webook passed" do
      before do
        allow(Settings.slack.webhooks).to receive(:default).and_return(default_webhook)
        allow(Slack::Notifier).to receive(:new).with(default_webhook).and_return(slack_notifier)
      end

      it "sends a message using the default webhook" do
        expect(slack_notifier).to receive(:ping).with(message, icon_emoji: icon_emoji, username: username)
        described_class.call(message: message, username: username)
      end
    end

    context "when no webook passed" do
      before do
        allow(Slack::Notifier).to receive(:new).with(channel_webhook).and_return(slack_notifier)
      end

      it "sends a message using the passed webhook" do
        expect(slack_notifier).to receive(:ping).with(message, icon_emoji: icon_emoji, username: username)
        described_class.call(channel_webhook: channel_webhook, message: message, username: username)
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe SlackNotifierService do
  let(:channel) { "channel" }
  let(:message) { "hello world" }
  let(:slack_webhook_url) { "/slack_webhook_url" }
  let(:slack_notifier) { instance_double(Slack::Notifier) }

  describe "#call" do
    before do
      allow(Settings.slack).to receive(:webhook_url).and_return(slack_webhook_url)
      allow(Settings.slack).to receive(:default_channel).and_return(channel)
      allow(Slack::Notifier).to receive(:new).with(slack_webhook_url).and_return(slack_notifier)
    end

    it "sends a message to the slack channel" do
      expect(slack_notifier).to receive(:ping).with(message, channel: channel)
      described_class.call(channel: channel, message: message)
    end
  end
end

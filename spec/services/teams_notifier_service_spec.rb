# frozen_string_literal: true

require "rails_helper"

describe TeamsNotifierService do
  let(:channel_webhook) { "https://example.com/teamswebhook" }
  let(:default_webhook) { "https://example.com/defaultteamswebhook" }
  let(:title) { "Notification Title" }
  let(:message) { "Notification message" }
  let(:icon_emoji) { "🚨" }
  let(:default_icon_emoji) { "🐙" }

  describe "#call" do
    context "when no webhook is passed" do
      before do
        allow(Settings.notifications.teams.webhooks).to receive(:register_support_channel).and_return(default_webhook)
        allow(TeamsWebhook::Client).to receive(:post)
      end

      it "sends a message using the default webhook" do
        expect(TeamsWebhook::Client).to receive(:post) do |webhook, options|
          payload = JSON.parse(options[:body])

          expect(webhook).to eq(default_webhook)
          expect(payload.dig("body", 1, "items", 0, "text")).to eq("#{icon_emoji} #{title}")
          expect(payload.dig("body", 1, "items", 1, "text")).to eq(message)
        end

        described_class.call(title:, message:, icon_emoji:)
      end

      it "uses the default icon when icon_emoji is not provided" do
        expect(TeamsWebhook::Client).to receive(:post) do |webhook, options|
          payload = JSON.parse(options[:body])

          expect(webhook).to eq(default_webhook)
          expect(payload.dig("body", 1, "items", 0, "text")).to eq("#{default_icon_emoji} #{title}")
          expect(payload.dig("body", 1, "items", 1, "text")).to eq(message)
        end

        described_class.call(title:, message:)
      end
    end

    context "when webhook is passed" do
      before do
        allow(TeamsWebhook::Client).to receive(:post)
      end

      it "sends a message using the passed webhook" do
        expect(TeamsWebhook::Client).to receive(:post) do |webhook, options|
          payload = JSON.parse(options[:body])

          expect(webhook).to eq(channel_webhook)
          expect(payload.dig("body", 1, "items", 0, "text")).to eq("#{icon_emoji} #{title}")
          expect(payload.dig("body", 1, "items", 1, "text")).to eq(message)
        end

        described_class.call(channel_webhook:, title:, message:, icon_emoji:)
      end
    end
  end
end

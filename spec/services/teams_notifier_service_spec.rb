# frozen_string_literal: true

require "rails_helper"

describe TeamsNotifierService do
  let(:channel_webhook) { "https://example.com/teamswebhook" }
  let(:default_webhook) { "https://example.com/defaultteamswebhook" }
  let(:message) { "hello world" }
  let(:icon_emoji) { "&#x1F419;" }
  let(:teams_message) { instance_double(MicrosoftTeamsIncomingWebhookRuby::Message, send: true) }

  describe "#call" do
    context "when no webhook is passed" do
      before do
        allow(Settings.notifications.teams.webhooks).to receive(:register_support_channel).and_return(default_webhook)
        allow(MicrosoftTeamsIncomingWebhookRuby::Message).to receive(:new).and_yield(builder).and_return(teams_message)
      end

      let(:builder) { double(:builder, :url= => nil, :text= => nil) }

      it "sends a message using the default webhook" do
        expect(builder).to receive(:url=).with(default_webhook)
        expect(builder).to receive(:text=).with("#{icon_emoji} #{message}")
        expect(teams_message).to receive(:send)

        described_class.call(message:)
      end
    end

    context "when webhook is passed" do
      before do
        allow(MicrosoftTeamsIncomingWebhookRuby::Message).to receive(:new).and_yield(builder).and_return(teams_message)
      end

      let(:builder) { double(:builder, :url= => nil, :text= => nil) }

      it "sends a message using the passed webhook" do
        expect(builder).to receive(:url=).with(channel_webhook)
        expect(builder).to receive(:text=).with("#{icon_emoji} #{message}")
        expect(teams_message).to receive(:send)

        described_class.call(channel_webhook:, message:, icon_emoji:)
      end
    end
  end
end

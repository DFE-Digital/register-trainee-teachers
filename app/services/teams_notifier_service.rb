# frozen_string_literal: true

class TeamsNotifierService
  include ServicePattern

  def initialize(channel_webhook: Settings.notifications.teams.webhooks.register_support_channel, message:, icon_emoji: "&#x1F419;")
    @channel_webhook = channel_webhook
    @message = message
    @icon_emoji = icon_emoji
  end

  def call
    TeamsWebhook::Client.post(channel_webhook, body: { text: formatted_text }.to_json)
  end

private

  attr_reader :channel_webhook, :message, :icon_emoji

  def formatted_text
    [icon_emoji, message].compact.join(" ").strip
  end
end

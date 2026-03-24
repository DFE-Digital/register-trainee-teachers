# frozen_string_literal: true

require "microsoft_teams_incoming_webhook_ruby"

class TeamsNotifierService
  include ServicePattern

  def initialize(channel_webhook: Settings.notifications.teams.webhooks.register_support_channel, message:, icon_emoji: "&#x1F419;")
    @channel_webhook = channel_webhook
    @message = message
    @icon_emoji = icon_emoji
  end

  def call
    teams_message.send
  end

private

  attr_reader :channel_webhook, :message, :icon_emoji

  def teams_message
    MicrosoftTeamsIncomingWebhookRuby::Message.new do |m|
      m.url = channel_webhook
      m.text = formatted_text
    end
  end

  def formatted_text
    "#{icon_emoji} #{message}"
  end
end

# frozen_string_literal: true

require "slack-notifier"

class SlackNotifierService
  include ServicePattern

  def initialize(channel_webhook: Settings.slack.webhooks.default, message:, username:, icon_emoji: ":inky-the-octopus:")
    @message = message
    @notifier = Slack::Notifier.new(channel_webhook)
    @icon_emoji = icon_emoji
    @username = username
  end

  def call
    notifier.ping(message, icon_emoji: icon_emoji, username: username)
  end

private

  attr_reader :notifier, :message, :icon_emoji, :username
end

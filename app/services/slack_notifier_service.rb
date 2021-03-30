# frozen_string_literal: true

require "slack-notifier"

class SlackNotifierService
  include ServicePattern

  def initialize(channel: Settings.slack.default_channel, message:, username:, icon_emoji: ":inky-the-octopus:")
    @channel = channel
    @message = message
    @notifier = Slack::Notifier.new(Settings.slack.webhook_url)
    @icon_emoji = icon_emoji
    @username = username
  end

  def call
    @notifier.ping(@message, channel: @channel, icon_emoji: @icon_emoji, username: @username)
  end
end

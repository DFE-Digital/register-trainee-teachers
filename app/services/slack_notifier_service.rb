# frozen_string_literal: true

require "slack-notifier"

class SlackNotifierService
  include ServicePattern

  def initialize(channel: Settings.slack.default_channel, message:)
    @channel = channel
    @message = message
    @notifier = Slack::Notifier.new(Settings.slack.webhook_url)
  end

  def call
    @notifier.ping(@message, channel: @channel)
  end
end

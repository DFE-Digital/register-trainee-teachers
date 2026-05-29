# frozen_string_literal: true

class TeamsNotifierService
  include ServicePattern

  def initialize(channel_webhook: Settings.notifications.teams.webhooks.register_support_channel, title: "", message:, icon_emoji: "🐙")
    @channel_webhook = channel_webhook
    @title = title
    @message = message
    @icon_emoji = icon_emoji
  end

  def call
    TeamsWebhook::Client.post(channel_webhook, body: message_template(title:, message:, icon_emoji:))
  end

private

  attr_reader :channel_webhook, :title, :message, :icon_emoji

  def message_template(title:, message:, icon_emoji:)
    {
      "$schema": "https://adaptivecards.io/schemas/adaptive-card.json",
      type: "AdaptiveCard",
      version: "1.0",
      body: [
        {
          type: "ColumnSet",
          id: "1ede2aba-61b9-faa0-9895-9ed0c26b2e6f",
          columns: [
            {
              type: "Column",
              id: "e5756242-0963-37a2-7cb4-4397886d60bb",
              padding: "None",
              width: "stretch",
              items: [
                {
                  type: "TextBlock",
                  id: "20f3833e-0435-5c87-fad1-b528e0046fb6",
                  text: "Inky the Octopus",
                  wrap: true,
                },
              ],
              verticalContentAlignment: "Center",
            },
            {
              type: "Column",
              id: "74215a26-fa8b-e549-cced-7f99fd34a661",
              padding: "None",
              width: "auto",
              items: [
                {
                  type: "Image",
                  id: "795047e2-e63e-6e14-07ba-5a3e13323dff",
                  url: "https://avatars.slack-edge.com/2021-05-11/2045496332774_b7a32efdfed4023bbba6_512.png",
                  size: "small",
                },
              ],
              horizontalAlignment: "Right",
            },
          ],
          padding: {
            top: "Small",
            bottom: "Small",
            left: "Default",
            right: "Small",
          },
          style: "emphasis",
        },
        {
          type: "Container",
          id: "fbcee869-2754-287d-bb37-145a4ccd750b",
          padding: "Default",
          spacing: "None",
          items: [
            {
              type: "TextBlock",
              id: "44906797-222f-9fe2-0b7a-e3ee21c6e380",
              text: "#{icon_emoji} #{title}",
              wrap: true,
              weight: "Bolder",
              size: "Large",
              style: "heading",
            },
            {
              type: "TextBlock",
              id: "f7abdf1a-3cce-2159-28ef-f2f362ec937e",
              text: message,
              wrap: true,
            },
          ],
        },
        {
          type: "Container",
          id: "77102c5d-fde2-e573-4ea5-66022d646d64",
          padding: {
            top: "Small",
            bottom: "Small",
            left: "Small",
            right: "Default",
          },
          spacing: "None",
          separator: true,
          items: [
            {
              type: "TextBlock",
              id: "42654e7e-cece-b419-867a-3e3ef4076870",
              text: "[Go to Register support console](https://www.register-trainee-teachers.service.gov.uk/system-admin/users)",
              wrap: true,
              color: "Accent",
              horizontalAlignment: "Right",
            },
          ],
          horizontalAlignment: "Right",
        },
      ],
      padding: "None",
    }.to_json
  end
end

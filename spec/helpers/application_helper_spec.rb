# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper do
  include ApplicationHelper

  describe "#govuk_button_link_to" do
    it "returns an anchor tag with the govuk-button class and button role" do
      anchor_tag = helper.govuk_button_link_to("Hoot", "https://localhost:0103/owl/hoot")

      expect(anchor_tag).to eq('<a class="govuk-button" role="button" draggable="false" href="https://localhost:0103/owl/hoot">Hoot</a>')
    end

    it "returns an anchor tag with additional HTML options" do
      anchor_tag = helper.govuk_button_link_to("Cluck", "https://localhost:0103/chicken/cluck", class: "govuk-button--start")

      expect(anchor_tag).to eq('<a class="govuk-button govuk-button--start" role="button" draggable="false" href="https://localhost:0103/chicken/cluck">Cluck</a>')
    end
  end
end

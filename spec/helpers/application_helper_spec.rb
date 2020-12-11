# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper do
  include ApplicationHelper

  describe "#govuk_button_link_to" do
    context "default behaviour" do
      subject { helper.govuk_button_link_to("Hoot", "https://localhost:0103/owl/hoot") }

      it "returns an anchor tag with the govuk-button class and button role" do
        expected_output = '<a role="button" data-module="govuk-button" draggable="false" class="govuk-button" href="https://localhost:0103/owl/hoot">Hoot</a>'

        expect(subject).to eq(expected_output)
      end
    end

    context "with options" do
      subject do
        helper.govuk_button_link_to("Cluck", "https://localhost:0103/chicken/cluck", class: "govuk-button--start")
      end

      it "returns the correct markup with the extra options applied" do
        expected_output = '<a role="button" data-module="govuk-button" draggable="false" class="govuk-button govuk-button--start" href="https://localhost:0103/chicken/cluck">Cluck</a>'

        expect(subject).to eq(expected_output)
      end
    end
  end
end

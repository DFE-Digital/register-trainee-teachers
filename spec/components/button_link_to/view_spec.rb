# frozen_string_literal: true

require "rails_helper"

module ButtonLinkTo
  describe View do
    alias_method :component, :page

    context "default behaviour" do
      subject { described_class.new(body: "Hoot", url: "https://localhost:0103/owl/hoot").call }

      it "returns an anchor tag with the govuk-button class and button role" do
        expected_output = '<a role="button" data-module="govuk-button" draggable="false" class="govuk-button" href="https://localhost:0103/owl/hoot">Hoot</a>'

        expect(subject).to eq(expected_output)
      end
    end

    context "with options" do
      subject do
        described_class.new(body: "Cluck", url: "https://localhost:0103/chicken/cluck", class_option: "govuk-button--start").call
      end

      it "returns the correct markup with the extra options applied" do
        expected_output = '<a role="button" data-module="govuk-button" draggable="false" class="govuk-button govuk-button--start" href="https://localhost:0103/chicken/cluck">Cluck</a>'

        expect(subject).to eq(expected_output)
      end
    end
  end
end

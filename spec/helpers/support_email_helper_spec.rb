# frozen_string_literal: true

require "rails_helper"

describe SupportEmailHelper do
  include SupportEmailHelper

  describe "#support_email" do
    has_correct_formatting = "has the correct formatting"
    context "without params" do
      subject { helper.support_email }

      it has_correct_formatting do
        expected_output = "<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk\">becomingateacher@digital.education.gov.uk</a>"
        expect(subject).to eq(expected_output)
      end
    end

    context "with subject" do
      subject { helper.support_email(subject: "Register trainee teachers support") }

      it has_correct_formatting do
        expected_output = "<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk?subject=Register%20trainee%20teachers%20support\">becomingateacher@digital.education.gov.uk</a>"
        expect(subject).to eq(expected_output)
      end

      context "with name" do
        subject { helper.support_email(name: "give feedback or report a problem", subject: "Register trainee teachers feedback") }
        it "has the correct formatting" do
          expected_output = "<a class=\"govuk-link\" href=\"mailto:becomingateacher@digital.education.gov.uk?subject=Register%20trainee%20teachers%20feedback\">give feedback or report a problem</a>"
          expect(subject).to eq(expected_output)
        end
        context "with class" do
          subject { helper.support_email(name: "give feedback or report a problem", subject: "Register trainee teachers feedback", classes: "govuk-link--no-visited-state") }
          it has_correct_formatting do
            expected_output = "<a class=\"govuk-link govuk-link--no-visited-state\" href=\"mailto:becomingateacher@digital.education.gov.uk?subject=Register%20trainee%20teachers%20feedback\">give feedback or report a problem</a>"
            expect(subject).to eq(expected_output)
          end
        end
      end
    end
  end
end

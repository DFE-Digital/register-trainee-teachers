# frozen_string_literal: true

require "rails_helper"

describe MappableFieldRow do
  describe "#to_h" do
    let(:record_id) { "WUtHPtyT4JmACiTQGh8YywDn" }
    let(:field_name) { :subject }
    let(:field_label) { "Subject" }
    let(:field_value) { nil }
    let(:has_errors) { nil }
    let(:action_url) { "/abc" }
    let(:apply_subject_value) { "Master's Degree" }

    subject do
      described_class.new(
        invalid_data: invalid_data,
        record_id: record_id,
        field_name: field_name,
        field_value: field_value,
        field_label: field_label,
        text: "not recognised",
        action_url: action_url,
        has_errors: has_errors,
        apply_draft: true,
        editable: true,
      ).to_h
    end

    context "field value matches error value" do
      let(:invalid_data) { { record_id => { "subject" => apply_subject_value } } }

      let(:expected_html) do
        <<~HTML
          <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding">
            <p class="app-inset-text__title govuk-!-margin-bottom-2">#{field_label} is not recognised</p>
            <div class="govuk-!-margin-bottom-1">#{apply_subject_value}</div>
            <div>
              <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" name="#{field_label.downcase}" href="#{action_url}">
                Review the trainee’s answer<span class="govuk-visually-hidden"> for #{field_label.downcase}</span>
              </a>
            </div>
          </div>
        HTML
      end

      it "returns HTML to inform user that field value is not recognised and needs changing" do
        expect(subject[:value]).to eq(expected_html)
      end

      it "doesn't set the action_href key" do
        expect(subject).not_to have_key(:action_href)
      end

      context "when has_errors is set to true" do
        let(:has_errors) { true }

        it "uses the app-inset-text--error class" do
          expect(subject[:value]).to include("app-inset-text--error")
        end

        it "has a visually hidden error prefix" do
          expect(subject[:value]).to include('<span class="govuk-visually-hidden">Error:</span>')
        end
      end
    end

    context "field value is not listed in the errors" do
      let(:invalid_data) { {} }
      let(:field_value) { "History" }

      it "returns field value" do
        expect(subject[:value]).to eq(field_value)
      end

      it "sets the action_href key" do
        expect(subject[:action_href]).to eq(action_url)
      end

      it "sets the action_text key" do
        expect(subject[:action_text]).to eq("Change")
      end

      it "sets the action_visually_hidden_text key to the field_name" do
        expect(subject[:action_visually_hidden_text]).to eq(field_label.downcase)
      end
    end

    context "no has_errors but value missing" do
      subject do
        described_class.new(
          field_value: nil,
          field_label: field_label,
          text: "missing",
          action_url: action_url,
          apply_draft: true,
          editable: true,
        ).to_h
      end

      let(:expected_html) do
        <<~HTML
          <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding">
            <p class="app-inset-text__title govuk-!-margin-bottom-2">#{field_label} is missing</p>
          #{'  '}
            <div>
              <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" name="#{field_label.downcase}" href="#{action_url}">
                Review the trainee’s answer<span class="govuk-visually-hidden"> for #{field_label.downcase}</span>
              </a>
            </div>
          </div>
        HTML
      end

      it "returns HTML excluding information about error value since it's not available" do
        expect(subject[:value]).to eq(expected_html)
      end
    end

    context "read_only/non-editable" do
      subject do
        described_class.new(
          field_value: field_value,
          field_label: field_label,
          action_url: action_url,
          apply_draft: false,
          editable: false,
        ).to_h
      end

      it "does not render change link" do
        expect(subject[:action_href]).to be_nil
        expect(subject[:action_text]).to be_nil
        expect(subject[:action_visually_hidden_text]).to be_nil
        expect(subject[:value]).to eq("Not provided")
      end

      context "when field value exists" do
        let(:field_value) { "History" }

        it "renders the provided value" do
          expect(subject[:value]).to eq("History")
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

describe MappableFieldRow do
  describe "#to_h" do
    let(:record_id) { "WUtHPtyT4JmACiTQGh8YywDn" }
    let(:field_name) { :subject }
    let(:field_label) { "Subject" }
    let(:field_value) { nil }
    let(:action_url) { "/abc" }
    let(:apply_subject_value) { "Master's Degree" }

    subject do
      described_class.new(invalid_data: invalid_data,
                          record_id: record_id,
                          field_name: field_name,
                          field_value: field_value,
                          field_label: field_label,
                          action_url: action_url).to_h
    end

    context "field value matches error value" do
      let(:invalid_data) { { record_id => { "subject" => apply_subject_value } } }

      let(:expected_html) do
        <<~HTML
          <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding">
            <p class="app-inset-text__title govuk-!-margin-bottom-2">#{field_label} is not recognised</p>
            <div class="govuk-!-margin-bottom-1">#{apply_subject_value}</div>
            <div>
              <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" href="#{action_url}">
                Review the trainee’s answer<span class="govuk-visually-hidden"> for #{field_label.downcase}</span>
              </a>
            </div>
          </div>
        HTML
      end

      it "returns HTML to inform user that field value is not recognised and needs changing" do
        expect(subject[:value]).to eq(expected_html)
      end

      it "doesn't set the action key" do
        expect(subject).not_to have_key(:action)
      end
    end

    context "field value is not listed in the errors" do
      let(:invalid_data) { {} }
      let(:field_value) { "History" }

      it "returns field value" do
        expect(subject[:value]).to eq(field_value)
      end

      it "sets the action key" do
        expect(subject[:action]).to eq(
          %(<a class="govuk-link" href="/abc">Change <span class="govuk-visually-hidden">#{field_label.downcase}</span></a>),
        )
      end
    end

    context "no error but value missing" do
      subject do
        described_class.new(field_value: nil,
                            field_label: field_label,
                            text: "missing",
                            action_url: action_url).to_h
      end

      let(:expected_html) do
        <<~HTML
          <div class="govuk-inset-text app-inset-text--narrow-border app-inset-text--important app-inset-text--no_padding">
            <p class="app-inset-text__title govuk-!-margin-bottom-2">#{field_label} is missing</p>
            #{''}
            <div>
              <a class="govuk-link govuk-link--no-visited-state app-summary-list__link--invalid" href="#{action_url}">
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
  end
end

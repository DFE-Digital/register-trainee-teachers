# frozen_string_literal: true

require "rails_helper"

describe MissingDataBannerView do
  include Rails.application.routes.url_helpers

  let(:missing_fields) { Submissions::MissingDataValidator.new(trainee: trainee).missing_fields }

  subject { described_class.new(missing_fields, trainee).content }

  describe "#content" do
    context "when there is no missing data" do
      let(:trainee) { create(:trainee, :completed) }

      it "returns nothing" do
        expect(subject).to be_falsey
      end
    end

    context "when the trainee is missing data" do
      let(:trainee) { create(:trainee, :completed, :course_start_date_in_the_past, field => nil) }

      let(:expected_display_name) { I18n.t("views.missing_data_view.missing_fields_mapping.#{field}") }
      let(:expected_html) do
        "<ul class=\"govuk-list app-notice-banner__list\"><li><a class=\"govuk-notification-banner__link\" href=\"#{expected_path}\">#{expected_display_name} is missing</a></li></ul>"
      end

      context "first_names" do
        let(:field) { :first_names }
        let(:expected_path) { edit_trainee_personal_details_path(trainee) }

        it "returns the link to the form containing the missing data" do
          expect(subject).to eq(expected_html)
        end
      end

      context "commencement_date" do
        let(:field) { :commencement_date }
        let(:expected_path) { edit_trainee_start_date_path(trainee) }

        it "returns the link to the form containing the missing data" do
          expect(subject).to eq(expected_html)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  describe InvalidDegreeView do
    let(:degree_slug) { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s }
    let(:application) { build(:apply_application, :with_invalid_data, degree_slug:) }

    subject(:invalid_degree_view) { described_class.new(application, degree_slug) }

    describe "#summary_content" do
      context "when there is only one invalid data" do
        it "returns the singular invalid answer summary" do
          expected_text = I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: 1)
          expect(subject.summary_content).to eq(expected_text)
        end
      end

      context "when there are multiple invalid data" do
        let(:application) { create(:apply_application, :with_multiple_invalid_data, degree_slug:) }

        it "returns the pluralised invalid answer summary" do
          expected_text = I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: 2)
          expect(subject.summary_content).to eq(expected_text)
        end
      end
    end

    describe "#invalid_data?" do
      subject { invalid_degree_view.invalid_data? }

      it { is_expected.to be_truthy }

      context "when there are no invalid data" do
        let(:application) { build(:apply_application, degree_slug:) }

        it { is_expected.to be_falsey }
      end
    end

    describe "#summary_items_content" do
      it "returns the invalid answer summary items" do
        expected_markup = "<li><a class=\"govuk-notification-banner__link\" href=\"#degree-awarding-institution-field\">Awarding institution is not recognised</a></li>"
        expect(subject.summary_items_content).to include(expected_markup)
      end
    end
  end
end

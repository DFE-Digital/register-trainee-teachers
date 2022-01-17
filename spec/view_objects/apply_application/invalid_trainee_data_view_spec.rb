# frozen_string_literal: true

require "rails_helper"

module ApplyApplications
  describe InvalidTraineeDataView do
    let(:degree_slug) { SecureRandom.base58(Sluggable::SLUG_LENGTH).to_s }
    let(:invalid_institution) { "Institution" }
    let(:invalid_subject) { "History1" }
    let(:trainee) { create(:trainee, apply_application: application) }
    let(:trainee_data_form) { ApplyApplications::TraineeDataForm.new(trainee, include_degree_id: true) }
    let(:degree_attributes) { { institution: invalid_institution } }
    let(:application) do
      create(:apply_application,
             :with_invalid_data,
             degree_slug: degree_slug,
             invalid_institution: invalid_institution)
    end

    before do
      create(:degree, :uk_degree_with_details, trainee: trainee, slug: degree_slug, **degree_attributes)
      trainee.nationalities << create(:nationality)
    end

    subject { described_class.new(trainee, trainee_data_form) }

    describe "#summary_content" do
      context "when there is only one invalid data" do
        it "returns the singular invalid answer summary" do
          expect(subject.summary_content).to eq(
            I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: 1),
          )
        end
      end

      context "when there are multiple invalid data" do
        let(:degree_attributes) { { subject: invalid_subject, institution: invalid_institution } }
        let(:application) do
          create(:apply_application,
                 :with_multiple_invalid_data,
                 degree_slug: degree_slug,
                 invalid_institution: invalid_institution,
                 invalid_subject: invalid_subject)
        end

        it "returns the pluralised invalid answer summary" do
          expected_text = I18n.t("views.apply_invalid_data_view.invalid_answers_summary", count: 2)

          expect(subject.summary_content).to eq(expected_text)
        end
      end
    end

    describe "#invalid_data?" do
      it "returns false when there is invalid data" do
        expect(subject.invalid_data?).to be_truthy
      end
    end

    describe "#summary_items_content" do
      it "returns the invalid answer summary items" do
        expected_markup = "<li><a class=\"govuk-notification-banner__link\" href=\"#awarding-institution-1\">Awarding institution is not recognised</a></li>"
        expect(subject.summary_items_content).to include(expected_markup)
      end

      context "no errors but no degrees" do
        before { trainee.degrees.delete_all }

        it "returns a link anchored to the degrees section" do
          expected_markup = "<li><a class=\"govuk-notification-banner__link\" href=\"#degrees\">Degree details not provided</a></li>"
          expect(subject.summary_items_content).to include(expected_markup)
        end
      end
    end
  end
end

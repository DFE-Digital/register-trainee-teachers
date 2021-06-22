# frozen_string_literal: true

require "rails_helper"

module Sections
  describe View do
    alias_method :component, :page

    let(:trainees_sections_component) do
      form = TrnSubmissionForm.new(trainee: trainee)
      described_class.new(trainee: trainee, section: section, form: form)
    end

    before do
      render_inline(trainees_sections_component)
    end

    renders_confirmation = "renders confirmation"
    shared_examples renders_confirmation do |trainee_section|
      context trainee_section.to_s do
        let(:section) { trainee_section }

        it "return correct component to render" do
          expect(trainees_sections_component.component).not_to be_a(CollapsedSection::View)
          expect(trainees_sections_component.component).to be_a(expected_confirmation_view(section))
        end
      end
    end

    renders_incomplete_section = "renders CollapsedSection"
    shared_examples renders_incomplete_section do |trainee_section, status|
      context trainee_section.to_s do
        let(:section) { trainee_section }

        it "return correct component to render" do
          expect(trainees_sections_component.component).to be_a(CollapsedSection::View)
        end

        it "has title" do
          expect(component).to have_css(".app-inset-text__title", text: expected_title(section, status))
        end

        it "has link" do
          expect(component).to have_link(expected_link_text(section, status), href: expected_href(section, status, trainee))
        end
      end
    end

    context "trainee not started" do
      let(:trainee) { create(:trainee, :not_started) }

      include_examples renders_incomplete_section, :personal_details, :not_started
      include_examples renders_incomplete_section, :contact_details, :not_started
      include_examples renders_incomplete_section, :diversity, :not_started
      include_examples renders_incomplete_section, :degrees, :not_started
      include_examples renders_incomplete_section, :course_details, :not_started
      include_examples renders_incomplete_section, :training_details, :not_started

      context "requires school" do
        include_examples renders_incomplete_section, :schools, :not_started
      end
    end

    context "trainee in progress" do
      let(:trainee) { create(:trainee, :in_progress) }

      include_examples renders_incomplete_section, :personal_details, :in_progress
      include_examples renders_incomplete_section, :contact_details, :in_progress
      include_examples renders_incomplete_section, :diversity, :in_progress
      include_examples renders_incomplete_section, :degrees, :in_progress
      include_examples renders_incomplete_section, :course_details, :in_progress
      include_examples renders_incomplete_section, :training_details, :in_progress

      context "requires school" do
        let(:trainee) { create(:trainee, :with_lead_school, :in_progress) }

        include_examples renders_incomplete_section, :schools, :in_progress
      end
    end

    context "trainee completed" do
      let(:trainee) do
        create(:trainee, :completed, course_code: nil)
      end

      include_examples renders_confirmation, :personal_details
      include_examples renders_confirmation, :contact_details
      include_examples renders_confirmation, :diversity
      include_examples renders_confirmation, :degrees
      include_examples renders_confirmation, :course_details
      include_examples renders_confirmation, :training_details

      context "requires school" do
        let(:trainee) { create(:trainee, :with_lead_school, :completed) }

        include_examples renders_confirmation, :schools
      end
    end

    def expected_title(section, status)
      "#{I18n.t("components.sections.titles.#{section}")} #{I18n.t("components.sections.statuses.#{status}")}"
    end

    def expected_link_text(_section, status)
      I18n.t("components.sections.link_texts.#{status}")
    end

    def expected_href(section, status, trainee)
      path = expected_path(section, status)
      Rails.application.routes.url_helpers.public_send(path, trainee)
    end

    def expected_path(section, status)
      {
        personal_details: {
          not_started: "edit_trainee_personal_details_path",
          in_progress: "trainee_personal_details_confirm_path",
        },
        contact_details: {
          not_started: "edit_trainee_contact_details_path",
          in_progress: "trainee_contact_details_confirm_path",
        },
        diversity: {
          not_started: "edit_trainee_diversity_disclosure_path",
          in_progress: "trainee_diversity_confirm_path",
        },
        degrees: {
          not_started: "trainee_degrees_new_type_path",
          in_progress: "trainee_degrees_confirm_path",
        },
        course_details: {
          not_started: "edit_trainee_course_details_path",
          in_progress: "trainee_course_details_confirm_path",
        },
        training_details: {
          not_started: "edit_trainee_training_details_path",
          in_progress: "trainee_training_details_confirm_path",
        },
        schools: {
          not_started: "edit_trainee_lead_schools_path",
          in_progress: "trainee_schools_confirm_path",
        },
      }[section][status]
    end

    def expected_confirmation_view(section)
      {
        personal_details: Confirmation::PersonalDetails::View,
        contact_details: Confirmation::ContactDetails::View,
        diversity: Confirmation::Diversity::View,
        degrees: Confirmation::Degrees::View,
        course_details: Confirmation::CourseDetails::View,
        training_details: Confirmation::TrainingDetails::View,
        schools: Confirmation::Schools::View,
      }[section]
    end
  end
end

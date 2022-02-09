# frozen_string_literal: true

require "rails_helper"

module Sections
  describe View do
    let(:trainees_sections_component) do
      form = Submissions::TrnValidator.new(trainee: trainee)
      described_class.new(trainee: trainee, section: section, form: form, editable: true)
    end

    before do
      render_inline(trainees_sections_component)
    end

    context "apply draft trainee in review" do
      let(:section) { :course_details }
      let(:status) { :review }
      let(:trainee) { create(:trainee, :in_progress, :with_apply_application) }

      it "renders section text for apply draft course details" do
        expect(rendered_component).to have_css(".app-inset-text__title", text: expected_title(section, status))
      end

      it "renders section link for apply draft course details section" do
        expect(rendered_component).to have_link(expected_link_text(section, status), href: expected_href(section, status, trainee))
      end
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
          expect(rendered_component).to have_css(".app-inset-text__title", text: expected_title(section, status))
        end

        it "has link" do
          expect(rendered_component).to have_link(expected_link_text(section, status), href: expected_href(section, status, trainee))
        end
      end
    end

    context "trainee incomplete" do
      let(:trainee) { create(:trainee, :incomplete) }

      include_examples renders_incomplete_section, :personal_details, :incomplete
      include_examples renders_incomplete_section, :contact_details, :incomplete
      include_examples renders_incomplete_section, :diversity, :incomplete
      include_examples renders_incomplete_section, :degrees, :incomplete
      include_examples renders_incomplete_section, :course_details, :incomplete
      include_examples renders_incomplete_section, :training_details, :incomplete
      include_examples renders_incomplete_section, :trainee_data, :incomplete
      include_examples renders_incomplete_section, :funding, :incomplete

      context "requires school" do
        include_examples renders_incomplete_section, :schools, :incomplete
      end

      context "trainee on publish course" do
        let(:provider) { create(:provider, :with_courses) }
        let(:trainee) { create(:trainee, :incomplete, training_route: provider.courses.first.route, provider: provider) }

        include_examples renders_incomplete_section, :course_details, :incomplete
      end

      context "trainee on early years route" do
        let(:trainee) { create(:trainee, :incomplete, training_route: "early_years_undergrad") }

        include_examples renders_incomplete_section, :course_details, :incomplete
      end
    end

    context "trainee in progress" do
      let(:trainee) { create(:trainee, :in_progress, applying_for_bursary: false, training_initiative: ROUTE_INITIATIVES_ENUMS[:transition_to_teach]) }

      # Personal details is invalid due to nationalities being missing
      include_examples renders_incomplete_section, :personal_details, :in_progress_invalid
      include_examples renders_incomplete_section, :contact_details, :in_progress_valid
      include_examples renders_incomplete_section, :diversity, :in_progress_valid
      include_examples renders_incomplete_section, :degrees, :in_progress_valid
      include_examples renders_incomplete_section, :course_details, :in_progress_valid
      include_examples renders_incomplete_section, :training_details, :in_progress_valid
      include_examples renders_incomplete_section, :trainee_data, :in_progress_valid
      include_examples renders_incomplete_section, :funding, :in_progress_valid

      context "requires school" do
        let(:trainee) { create(:trainee, :with_lead_school, :in_progress) }

        include_examples renders_incomplete_section, :schools, :in_progress_valid
      end
    end

    context "trainee completed" do
      let(:trainee) do
        create(
          :trainee,
          :completed,
          course_uuid: nil,
          applying_for_bursary: false,
          training_initiative: ROUTE_INITIATIVES_ENUMS[:transition_to_teach],
        )
      end

      include_examples renders_confirmation, :personal_details
      include_examples renders_confirmation, :contact_details
      include_examples renders_confirmation, :diversity
      include_examples renders_confirmation, :degrees
      include_examples renders_confirmation, :course_details
      include_examples renders_confirmation, :training_details
      include_examples renders_confirmation, :trainee_data
      include_examples renders_confirmation, :funding

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
          incomplete: "edit_trainee_personal_details_path",
          in_progress_invalid: "edit_trainee_personal_details_path",
        },
        contact_details: {
          incomplete: "edit_trainee_contact_details_path",
          in_progress_valid: "trainee_contact_details_confirm_path",
        },
        diversity: {
          incomplete: "edit_trainee_diversity_disclosure_path",
          in_progress_valid: "trainee_diversity_confirm_path",
        },
        degrees: {
          incomplete: "trainee_degrees_new_type_path",
          in_progress_valid: "trainee_degrees_confirm_path",
        },
        course_details: {
          incomplete: expected_incomplete_course_details_path(trainee),
          in_progress_valid: "trainee_course_details_confirm_path",
          review: "edit_trainee_apply_applications_course_details_path",
        },
        training_details: {
          incomplete: "edit_trainee_training_details_path",
          in_progress_valid: "trainee_training_details_confirm_path",
        },
        schools: {
          incomplete: "edit_trainee_lead_schools_path",
          in_progress_valid: "trainee_schools_confirm_path",
        },
        funding: {
          incomplete: "edit_trainee_funding_training_initiative_path",
          in_progress_valid: "trainee_funding_confirm_path",
        },
        trainee_data: {
          incomplete: "edit_trainee_apply_applications_trainee_data_path",
          in_progress_valid: "edit_trainee_apply_applications_trainee_data_path",
        },
      }[section][status]
    end

    def expected_confirmation_view(section)
      {
        personal_details: PersonalDetails::View,
        contact_details: ContactDetails::View,
        diversity: Diversity::View,
        degrees: Degrees::View,
        course_details: CourseDetails::View,
        training_details: TrainingDetails::View,
        schools: Schools::View,
        funding: Funding::View,
        trainee_data: ApplyApplications::TraineeData::View,
      }[section]
    end

    def expected_incomplete_course_details_path(trainee)
      if trainee.early_years_route?
        "edit_trainee_course_details_path"
      elsif trainee.available_courses.present?
        "edit_trainee_publish_course_details_path"
      else
        "edit_trainee_course_education_phase_path"
      end
    end
  end
end

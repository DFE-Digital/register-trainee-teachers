# frozen_string_literal: true

module Sections
  class View < ApplicationComponent
    def initialize(trainee:, section:, form:, editable:)
      @trainee = trainee
      @section = section
      @form = form
      @editable = editable
    end

    def component
      if display_type == :expanded
        confirmation_view.new(**confirmation_view_args)
      else
        CollapsedSection::View.new(**collapsed_section_args)
      end
    end

  private

    attr_accessor :trainee, :section, :form, :editable

    delegate :funding_options, to: :helpers

    def confirmation_view_args
      if section == :trainee_data
        { trainee_data_form: form_klass.new(trainee), editable: editable }
      else
        view_args = { data_model: form_klass.new(trainee), has_errors: form_has_errors?, editable: editable }

        if section == :degrees
          view_args.merge!(show_add_another_degree_button: true, show_delete_button: true)
        end
        view_args.merge!(header_level: 3)
        view_args
      end
    end

    def collapsed_funding_inactive_section_args
      { title: I18n.t("components.sections.titles.funding_inactive"), hint_text: I18n.t("components.sections.link_texts.funding_inactive"), has_errors: form_has_errors?, name: section }
    end

    def collapsed_section_args
      if section == :funding && funding_options(trainee) == :funding_inactive
        collapsed_funding_inactive_section_args
      else
        { title: title, link_text: link_text, url: url, has_errors: form_has_errors?, name: section }
      end
    end

    def form_klass
      case section
      when :schools
        Schools::FormValidator
      when :funding
        Funding::FormValidator
      when :trainee_data
        ApplyApplications::TraineeDataForm
      else
        "#{section.to_s.camelcase}Form".constantize
      end
    end

    def confirmation_view
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
        iqts_country: IqtsCountry::View,
        placements: PlacementDetails::View,
      }[section]
    end

    def path
      {
        personal_details: {
          incomplete: "edit_trainee_personal_details_path",
          in_progress_invalid: "edit_trainee_personal_details_path",
          in_progress_valid: "trainee_personal_details_confirm_path",
          review: "trainee_personal_details_confirm_path",
        },
        contact_details: {
          incomplete: "edit_trainee_contact_details_path",
          in_progress_invalid: "edit_trainee_contact_details_path",
          in_progress_valid: "trainee_contact_details_confirm_path",
          review: "trainee_contact_details_confirm_path",
        },
        diversity: {
          incomplete: "edit_trainee_diversity_disclosure_path",
          in_progress_invalid: "edit_trainee_diversity_disclosure_path",
          in_progress_valid: "trainee_diversity_confirm_path",
          review: "trainee_diversity_confirm_path",
        },
        degrees: {
          not_provided: "trainee_degrees_new_type_path",
          incomplete: "trainee_degrees_new_type_path",
          in_progress_invalid: "trainee_degrees_confirm_path",
          in_progress_valid: "trainee_degrees_confirm_path",
          review: "trainee_degrees_confirm_path",
        },
        course_details: {
          incomplete: path_for_incomplete_course_details(trainee),
          in_progress_invalid: "edit_trainee_course_education_phase_path",
          in_progress_valid: "trainee_course_details_confirm_path",
          review: "edit_trainee_apply_applications_course_details_path",
        },
        training_details: {
          incomplete: "edit_trainee_training_details_path",
          in_progress_invalid: "edit_trainee_training_details_path",
          in_progress_valid: "trainee_training_details_confirm_path",
          review: "trainee_training_details_confirm_path",
        },
        schools: {
          incomplete: "edit_trainee_lead_partners_path",
          in_progress_invalid: "edit_trainee_lead_partners_path",
          in_progress_valid: "trainee_schools_confirm_path",
          review: "trainee_schools_confirm_path",
        },
        funding: {
          incomplete: "edit_trainee_funding_training_initiative_path",
          in_progress_invalid: "edit_trainee_funding_training_initiative_path",
          in_progress_valid: "trainee_funding_confirm_path",
          review: "trainee_funding_confirm_path",
        },
        trainee_data: {
          incomplete: "edit_trainee_apply_applications_trainee_data_path",
          in_progress_invalid: "edit_trainee_apply_applications_trainee_data_path",
          in_progress_valid: "edit_trainee_apply_applications_trainee_data_path",
          review: "edit_trainee_apply_applications_trainee_data_path",
        },
        iqts_country: {
          incomplete: "edit_trainee_iqts_country_path",
          in_progress_invalid: "edit_trainee_iqts_country_path",
          in_progress_valid: "trainee_iqts_country_confirm_path",
          review: "trainee_iqts_country_confirm_path",
        },
        placements: {
          not_provided: "edit_trainee_placements_details_path",
          incomplete: "edit_trainee_placements_details_path",
          in_progress_invalid: "trainee_placements_confirm_path",
          in_progress_valid: "trainee_placements_confirm_path",
          review: "trainee_placements_confirm_path",
        },
      }[section][progress_status]
    end

    def form_has_errors?
      @form_has_errors ||= form.errors.present?
    end

    def progress_status
      @progress_status ||= form.progress_status(section)
    end

    def display_type
      @display_type ||= form.display_type(section)
    end

    def title
      "#{section_title} #{section_status}"
    end

    def section_title
      I18n.t("components.sections.titles.#{section}")
    end

    def section_status
      I18n.t("components.sections.statuses.#{progress_status}")
    end

    def url
      Rails.application.routes.url_helpers.public_send(path, trainee)
    end

    def link_text
      link_text = I18n.t("components.sections.link_texts.#{progress_status}")
      "#{link_text}<span class=\"govuk-visually-hidden\"> #{section_title.downcase}</span>".html_safe
    end

    def path_for_incomplete_course_details(trainee)
      return "edit_trainee_publish_course_details_path" if trainee.available_courses.present?
      return "edit_trainee_course_details_path" if trainee.early_years_route?

      "edit_trainee_course_education_phase_path"
    end
  end
end

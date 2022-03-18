# frozen_string_literal: true

module ApplicationRecordCard
  class View < GovukComponent::Base
    include SanitizeHelper
    include TraineeHelper
    include CourseDetailsHelper

    with_collection_parameter :record

    attr_reader :record, :heading_level, :current_user

    def initialize(heading_level = 3, record:, current_user:)
      @record = record
      @heading_level = heading_level
      @current_user = current_user
    end

    def trainee_name
      return I18n.t("components.application_record_card.trainee_name.blank") if has_no_name?

      params[:sort_by] == "last_name" ? last_name_first : first_names_first
    end

    def subject
      return I18n.t("components.application_record_card.subject.early_years") if record.early_years_route?
      return course_name_for(record) if record.course_subject_one.blank?

      subjects_for_summary_view(record.course_subject_one, record.course_subject_two, record.course_subject_three)
    end

    def route
      return "No route provided" if record.training_route.blank?

      t("activerecord.attributes.trainee.training_routes.#{record.training_route}")
    end

    def updated_at
      date_text = tag.span(last_updated_date.strftime("%-d %B %Y"))
      class_list = "govuk-caption-m govuk-!-font-size-16 govuk-!-margin-top-2 govuk-!-margin-bottom-0 application-record-card__submitted"

      sanitize(tag.p(date_text.prepend("Updated: "), class: class_list))
    end

    def last_updated_date
      return record.updated_at if record.draft?

      record.timeline&.first&.date.presence || record.updated_at
    end

    def trainee_id
      return if record.trainee_id.blank?

      tag.p("Trainee ID: #{record.trainee_id}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__id govuk-!-margin-top-0 govuk-!-margin-bottom-1")
    end

    def provider_name
      return unless show_provider

      tag.p(record.provider.name.to_s, class: "govuk-caption-m govuk-!-font-size-16 application-record-card__provider_name govuk-!-margin-bottom-0 govuk-!-margin-top-2")
    end

    def trn
      return if record.trn.blank?

      tag.p("TRN: #{record.trn}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__trn govuk-!-margin-bottom-0 govuk-!-margin-top-0")
    end

    def start_year
      academic_cycle = AcademicCycle.for_date(record.commencement_date)
      return unless academic_cycle

      year_text = "#{academic_cycle.start_year} to #{academic_cycle.start_year + 1}"
      tag.p("Start year: #{year_text}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__start_year govuk-!-margin-top-1 govuk-!-margin-bottom-1")
    end

    def show_provider
      current_user.system_admin? || current_user.lead_school?
    end

    def hide_progress_tag
      TraineePolicy.new(current_user, record).hide_progress_tag?
    end

  private

    def has_no_name?
      record.blank? || record.first_names.blank? || record.last_name.blank?
    end

    def first_names_first
      [record.first_names, record.last_name].join(" ")
    end

    def last_name_first
      [record.last_name, record.first_names].join(", ")
    end
  end
end

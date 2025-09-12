# frozen_string_literal: true

module ApplicationRecordCard
  class View < ApplicationComponent
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
      return I18n.t("components.application_record_card.trainee_name.blank") if no_name?

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
      record.updated_at
    end

    def provider_trainee_id
      return if record.provider_trainee_id.blank?

      tag.p("Trainee ID: #{record.provider_trainee_id}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__id govuk-!-margin-top-0 govuk-!-margin-bottom-1")
    end

    def provider_name
      return unless show_provider?

      tag.p(record.provider.name_and_code.to_s, class: "govuk-caption-m govuk-!-font-size-16 application-record-card__provider_name govuk-!-margin-bottom-0 govuk-!-margin-top-2")
    end

    def record_source
      return unless show_record_source?

      title = I18n.t("components.application_record_card.record_source.title")
      record_source_text = I18n.t("components.application_record_card.record_source.#{record.derived_record_source}")
      tag.p("#{title}: #{record_source_text}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__record_source govuk-!-margin-bottom-0 govuk-!-margin-top-2")
    end

    def trn
      return if record.trn.blank?

      tag.p("TRN: #{record.trn}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__trn govuk-!-margin-bottom-0 govuk-!-margin-top-0")
    end

    def start_year
      academic_cycle = record.start_academic_cycle || AcademicCycle.for_date(record.trainee_start_date)
      return unless academic_cycle

      tag.p("Start year: #{academic_cycle.label}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__start_year govuk-!-margin-top-1 govuk-!-margin-bottom-1")
    end

    def end_year
      academic_cycle = record.end_academic_cycle
      return unless academic_cycle

      tag.p("End year: #{academic_cycle.label}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__end_year govuk-!-margin-top-1 govuk-!-margin-bottom-1")
    end

    def show_provider?
      current_user.system_admin? || current_user.lead_partner?
    end

    def show_record_source?
      current_user.system_admin?
    end

    def hide_progress_tag?
      TraineePolicy.new(current_user, record).hide_progress_tag?
    end

  private

    def no_name?
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

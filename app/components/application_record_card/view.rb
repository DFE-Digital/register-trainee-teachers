# frozen_string_literal: true

module ApplicationRecordCard
  class View < GovukComponent::Base
    include SanitizeHelper
    include TraineeHelper
    include CourseDetailsHelper

    with_collection_parameter :record

    attr_reader :record, :heading_level, :system_admin

    def initialize(heading_level = 3, record:, system_admin:)
      @record = record
      @heading_level = heading_level
      @system_admin = system_admin
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
      date_stamp = record.timeline&.first&.date.presence || record.created_at
      date_text = tag.span(date_stamp.strftime("%-d %B %Y"))
      class_list = "govuk-caption-m govuk-!-font-size-16 govuk-!-margin-top-2 govuk-!-margin-bottom-0 application-record-card__submitted"

      sanitize(tag.p(date_text.prepend("Updated: "), class: class_list))
    end

    def trainee_id
      return if record.trainee_id.blank?

      tag.p("Trainee ID: #{record.trainee_id}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__id govuk-!-margin-top-0 govuk-!-margin-bottom-1")
    end

    def provider_name
      return unless system_admin

      tag.p("Provider: #{record.provider.name}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__provider_name govuk-!-margin-top-0 govuk-!-margin-bottom-1")
    end

    def trn
      return if record.trn.blank?

      tag.p("TRN: #{record.trn}", class: "govuk-caption-m govuk-!-font-size-16 application-record-card__trn govuk-!-margin-bottom-0 govuk-!-margin-top-0")
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

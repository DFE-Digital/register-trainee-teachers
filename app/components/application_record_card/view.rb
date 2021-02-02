# frozen_string_literal: true

module ApplicationRecordCard
  class View < GovukComponent::Base
    include SanitizeHelper
    include TraineeHelper

    with_collection_parameter :record

    attr_reader :record, :heading_level

    def initialize(heading_level = 2, record:)
      @record = record
      @heading_level = heading_level
    end

    def trainee_name
      return "Draft record" if record.blank? || record.first_names.blank? || record.last_name.blank?

      [record.first_names, record.last_name].join(" ")
    end

    def subject
      return "No subject provided" if record.subject.blank?

      record.subject
    end

    def route
      return "No route provided" if record.record_type.blank?

      record.record_type.humanize
    end

    def updated_at
      date_stamp = record.updated_at.presence || record.created_at
      date_text = tag.span(date_stamp.strftime("%-d %B %Y"))
      class_list = "govuk-caption-m govuk-!-font-size-16 govuk-!-margin-top-2 govuk-!-margin-bottom-0 app-application-card__submitted"

      sanitize(tag.p(date_text.prepend("Updated: "), class: class_list))
    end

    def trainee_id
      return if record.trainee_id.blank?

      tag.p("Trainee ID: " + record.trainee_id, class: "govuk-caption-m govuk-!-font-size-16 app-application-card__id govuk-!-margin-bottom-0")
    end

    def trn
      return if record.trn.blank?

      tag.p("TRN: " + record.trn, class: "govuk-caption-m govuk-!-font-size-16 app-application-card__trn govuk-!-margin-bottom-0 govuk-!-margin-top-0")
    end
  end
end

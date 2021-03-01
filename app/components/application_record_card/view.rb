# frozen_string_literal: true

module ApplicationRecordCard
  class View < GovukComponent::Base
    include SanitizeHelper
    include TraineeHelper

    with_collection_parameter :record

    attr_reader :record, :heading_level

    def initialize(heading_level = 3, record:)
      @record = record
      @heading_level = heading_level
    end

    def trainee_name
      return "Draft record" if record.blank? || record.first_names.blank? || record.last_name.blank?

      params[:sort_by] == "last_name" ? last_name_first : first_names_first
    end

    def subject
      return "No subject provided" if record.subject.blank?

      record.subject
    end

    def route
      return "No route provided" if record.training_route.blank?

      t('activerecord.attributes.trainee.training_routes.' + record.training_route)
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

  private

    def first_names_first
      [record.first_names, record.last_name].join(" ")
    end

    def last_name_first
      [record.last_name, record.first_names].join(", ")
    end
  end
end

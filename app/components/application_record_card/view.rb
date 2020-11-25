# frozen_string_literal: true

module ApplicationRecordCard
  class View < GovukComponent::Base
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
      return "ERROR: No route provided" if record.record_type.blank?

      record.record_type.humanize
    end

    def status
      "Draft"
    end
  end
end

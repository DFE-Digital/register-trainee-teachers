# frozen_string_literal: true

module Trainees
  class CreateTimeline
    include ServicePattern

    def initialize(audits:)
      @audits = audits
    end

    def call
      events.flatten.compact.sort_by(&:date).reverse
    end

  private

    attr_reader :audits

    def events
      trimmed_audits.map { |audit| CreateTimelineEvents.call(audit: audit) }
    end

    # The audited gem creates multiple audits when multiple associations are
    # created e.g. when a user saves more than one disability for a trainee.
    # For now, just show one 'create' timeline entry.
    def trimmed_audits
      grouped_audits.map { |_, audits| audits.first }
    end

    def grouped_audits
      audits.group_by(&:request_uuid)
    end
  end
end

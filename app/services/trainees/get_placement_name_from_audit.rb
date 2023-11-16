# frozen_string_literal: true

module Trainees
  class GetPlacementNameFromAudit
    include ServicePattern

    def initialize(audit:)
      @audit = audit
    end

    def call
      if @audit.action == "update"
        from_name = (School.find_by(id: from_school_id)&.name if from_school_id.present?) ||
          @audit.audited_changes["name"].first
        to_name = (School.find_by(id: to_school_id)&.name if to_school_id.present?) ||
          @audit.audited_changes["name"].last
        [from_name, to_name]
      else
        (School.find_by(id: school_id)&.name if school_id.present?) ||
          @audit.audited_changes["name"]
      end
    end

  private

    def school_id
      @audit.audited_changes["school_id"]
    end

    def from_school_id
      @audit.audited_changes["school_id"]&.first
    end

    def to_school_id
      @audit.audited_changes["school_id"]&.last
    end
  end
end

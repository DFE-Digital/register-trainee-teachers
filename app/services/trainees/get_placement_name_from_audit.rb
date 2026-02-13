# frozen_string_literal: true

module Trainees
  class GetPlacementNameFromAudit
    include ServicePattern

    def initialize(audit:)
      @audit = audit
    end

    def call
      if @audit.action == "update"
        [school_name(audit_value_position: :first), school_name(audit_value_position: :last)]
      else
        school_name(audit_value_position: nil)
      end
    end

  private

    def school_name(audit_value_position: nil)
      id = audit_value(field: "school_id", position: audit_value_position)

      # Try to find the name of the school from the id. Otherwise try "name" in the audited changes,
      # or return "Unknown school" if the school doesn't exist any more (probably deleted from GIAS).
      (School.find_by(id:)&.name if id.present?) ||
        audit_value(field: "name", position: audit_value_position) ||
        "Unknown school"
    end

    def audit_value(field:, position: nil)
      if position
        @audit.audited_changes[field]&.send(position)
      else
        @audit.audited_changes[field]
      end
    end
  end
end

# frozen_string_literal: true

module Trainees
  class CreateTimeline
    include ServicePattern

    def initialize(trainee:, current_user: nil)
      @trainee = trainee
      @current_user = current_user
    end

    def call
      events.flatten.compact.sort_by(&:date).reverse
    end

  private

    attr_reader :trainee, :current_user

    def events
      filtered_audits.map { |audit| CreateTimelineEvents.call(audit:, current_user:) }
    end

    def filtered_audits
      grouped_audits.reject do |audit|
        preceeds_trn?(audit) && !trainee_creation?(audit)
      end
    end

    def preceeds_trn?(audit)
      submitted_at = trainee.submitted_for_trn_at

      return false if !trainee.draft? && !submitted_at

      !submitted_at || audit.created_at < submitted_at
    end

    def trainee_creation?(audit)
      audit.auditable_type == "Trainee" && audit.action == "create"
    end

    # The audited gem creates multiple audits when multiple associations are
    # created e.g. when a user saves more than one disability for a trainee.
    # For now, just show one 'create' timeline entry.
    def grouped_audits
      audits.includes(:user).group_by(&:request_uuid).map { |_, audits| audits.first }
    end

    def audits
      trainee
        .own_and_associated_audits
        .where.not("username = ? AND auditable_type = ?", "HESA", "Degree")
    end
  end
end

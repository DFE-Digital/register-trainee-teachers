# frozen_string_literal: true

module Trainees
  class MapStateFromDttp
    include ServicePattern
    include HasDttpMapping

    # This is not the same order as the enum definition in the Trainee model
    STATUS_PROGRESS_ORDER = %w[
      draft
      submitted_for_trn
      trn_received
      recommended_for_award
      deferred
      withdrawn
      awarded
    ].freeze

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
    end

    def call
      if dttp_statuses.empty? || status_not_determinable? || mapped_statuses.empty?
        dttp_trainee.non_importable_missing_state!
        return
      end

      # Specific rule
      if dttp_statuses == [DttpStatuses::DEFERRED, DttpStatuses::STANDARDS_NOT_MET]
        return "deferred"
      end

      most_progressed_state
    end

  private

    attr_reader :dttp_trainee, :placement_assignment

    def dttp_statuses
      @dttp_statuses ||= [
        find_by_entity_id(dttp_trainee.response["_dfe_traineestatusid_value"], Dttp::CodeSets::Statuses::MAPPING),
        find_by_entity_id(dttp_trainee.latest_placement_assignment.response["_dfe_traineestatusid_value"], Dttp::CodeSets::Statuses::MAPPING),
      ].compact.sort
    end

    def status_not_determinable?
      non_determinable_statuses.include?(dttp_statuses)
    end

    def non_determinable_statuses
      [
        [DttpStatuses::AWAITING_QTS, DttpStatuses::STANDARDS_MET],
        [DttpStatuses::AWAITING_QTS, DttpStatuses::LEFT_COURSE_BEFORE_END],
        [DttpStatuses::DEFERRED, DttpStatuses::AWAITING_QTS],
        [DttpStatuses::DEFERRED, DttpStatuses::LEFT_COURSE_BEFORE_END],
        [DttpStatuses::DEFERRED, DttpStatuses::YET_TO_COMPLETE_COURSE],
      ].map(&:sort)
    end

    def mapped_statuses
      @mapped_statuses ||= dttp_statuses.map { |dttp_status| map_to_state(dttp_status) }.compact
    end

    def most_progressed_state
      mapped_statuses.max_by(&STATUS_PROGRESS_ORDER.method(:index))
    end

    def map_to_state(dttp_status)
      case dttp_status
      when DttpStatuses::DRAFT_RECORD then "draft"
      when DttpStatuses::PROSPECTIVE_TRAINEE_TRN_REQUESTED then "submitted_for_trn"
      when DttpStatuses::STANDARDS_MET, DttpStatuses::AWAITING_QTS then "recommended_for_award"
      when DttpStatuses::DEFERRED then "deferred"
      when DttpStatuses::YET_TO_COMPLETE_COURSE then "trn_received"
      when DttpStatuses::AWARDED_EYTS, DttpStatuses::AWARDED_QTS then "awarded"
      when DttpStatuses::LEFT_COURSE_BEFORE_END then "withdrawn"
      when DttpStatuses::STANDARDS_NOT_MET
        withdraw_date.present? ? "withdrawn" : "trn_received"
      when DttpStatuses::EYTS_REVOKED, DttpStatuses::QTS_REVOKED, DttpStatuses::DID_NOT_START, DttpStatuses::REJECTED then nil
      end
    end

    def withdraw_date
      dttp_trainee.latest_placement_assignment.response["dfe_dateleft"]
    end
  end
end

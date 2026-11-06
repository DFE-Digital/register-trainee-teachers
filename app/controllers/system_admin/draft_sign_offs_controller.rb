# frozen_string_literal: true

module SystemAdmin
  # One-person sign off of a draft year's funding requirements, from Drafts:
  # review the list → approve (declaration) → confirmation. Approving marks the
  # year Ready for release; it goes live on the academic year's start date. Until
  # then the year can be reopened for editing. Gated by funding_management_edit.
  class DraftSignOffsController < ApplicationController
    before_action { require_feature_flag(:funding_management) }
    before_action { require_feature_flag(:funding_management_edit) }
    before_action :set_academic_cycle
    before_action :require_signable, only: %i[show approve create]

    helper_method :academic_cycle

    def show
      @entries = draft_entries
    end

    def approve
      @entry_count = draft_entries.size
    end

    def create
      AcademicCycle.transaction do
        now = Time.zone.now
        academic_cycle.funding_publication_requests.create!(
          state: :approved, submitted_by: audit_user, submitted_at: now, reviewed_by: audit_user, reviewed_at: now,
        )
        academic_cycle.update!(published: true)
      end

      redirect_to(funding_management_draft_sign_off_confirmation_path(academic_year: academic_cycle.start_year))
    end

    def confirmation
      return drafts_redirect(alert: "#{name} have not been approved.") unless academic_cycle.ready_for_release? || academic_cycle.eytda_funding_approved?

      @approval = academic_cycle.latest_approval
    end

    # Back to Draft, keeping the approval in the history as withdrawn. Only
    # before go-live: after that, amendments need a Register developer.
    def reopen
      return drafts_redirect(alert: "Only funding requirements that are ready for release can be reopened.") unless academic_cycle.ready_for_release?

      AcademicCycle.transaction do
        academic_cycle.latest_approval&.update!(state: :withdrawn)
        academic_cycle.update!(published: false)
      end

      drafts_redirect(success: "#{name} reopened for editing")
    end

  private

    attr_reader :academic_cycle

    def set_academic_cycle
      @academic_cycle = AcademicCycle.for_year(params[:academic_year].to_i)
      drafts_redirect(alert: "That academic year was not found.") if @academic_cycle.nil?
    end

    # Only a draft year with at least one funding record can be signed off, or
    # 2026 to 2027 with EYTDA funding (it has gone live, but EYTDA is drafted for it).
    def require_signable
      return if academic_cycle.draft? && academic_cycle.funding_methods.exists?
      return if academic_cycle.eytda_funding_draftable? && academic_cycle.draft_funding_methods.exists?

      drafts_redirect(alert: "#{name} cannot be signed off.")
    end

    # The entries being signed off: EYTDA's only, in a year that's EYTDA only.
    def draft_entries
      entries = ::Funding::ReferenceQuery.new(academic_cycle).entries
      return entries unless academic_cycle.eytda_only_funding_year?

      entries.select { |entry| entry[:training_route].to_s == FundingManager::EYTDA_ROUTE }
    end

    def name
      "#{helpers.short_academic_year(academic_cycle)} funding requirements"
    end

    def drafts_redirect(flash_hash)
      redirect_to(funding_management_drafts_path, flash: flash_hash)
    end
  end
end

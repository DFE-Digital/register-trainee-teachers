# frozen_string_literal: true

module SystemAdmin
  # Read-only Funding management: browse the funding reference data
  # (FundingMethod / FundingMethodSubject / AllocationSubject) by academic
  # cycle, and export it. Editing is a separate, governed phase - this
  # controller never writes.
  class FundingMethodsController < ApplicationController
    ENTRIES_PER_PAGE = 25

    # Finishes a submission left awaiting approval by the old two-person flow.
    # New sign-offs go through the Drafts sign-off journey (DraftSignOffsController).
    APPROVAL_ACTIONS = %i[review_publication approve_publication reject_publication withdraw_publication].freeze

    before_action { require_feature_flag(:funding_management) }
    DELETE_ACTIONS = %i[destroy_selected destroy_entry confirm_delete_draft destroy_draft].freeze

    before_action -> { require_feature_flag(:funding_management_edit) }, only: %i[roll_over create_roll_over] + APPROVAL_ACTIONS + DELETE_ACTIONS
    before_action :set_academic_cycle

    helper_method :academic_cycle, :academic_cycles, :requirement_year_cycles, :viewing_draft_year?, :funding_query, :all_years?, :roll_over_source, :can_roll_over?, :can_delete_draft?, :funded_subjects

    def index
      entries = all_years? ? entries_outside_drafts : funding_query.entries
      @entries = Kaminari.paginate_array(apply_entry_filters(entries)).page(params[:page]).per(ENTRIES_PER_PAGE)
      load_carried_forward_entries unless all_years?
    end

    def show
      @training_route = params[:training_route]
      redirect_to(funding_management_requirements_path(academic_year: academic_cycle.start_year)) and return unless funding_query.route_funded?(@training_route)

      @bands = funding_query.route_bands(@training_route)
    end

    # Future years whose funding is still being prepared (draft or awaiting
    # approval, not yet published), soonest first, with their entry counts.
    def drafts
      @draft_cycles = in_progress_draft_cycles
      # One entry per funding record and subject, as counted on Requirements.
      @entry_counts = @draft_cycles.to_h { |cycle| [cycle.id, cycle.draft_funding_methods.joins(:funding_method_subjects).count] }
    end

    # Confirm page: delete all of a draft year's funding.
    def confirm_delete_draft
      return drafts_redirect(alert: "Only draft funding can be deleted.") unless can_delete_draft?

      @record_count = academic_cycle.draft_funding_methods.count
    end

    def destroy_draft
      return drafts_redirect(alert: "Only draft funding can be deleted.") unless can_delete_draft?

      count = academic_cycle.draft_funding_methods.count
      academic_cycle.draft_funding_methods.includes(:funding_method_subjects).destroy_all
      drafts_redirect(success: "Deleted #{academic_cycle.label} draft funding (#{count} funding #{'record'.pluralize(count)})")
    end

    def subject_records
      @records = funding_query.subject_records
    end

    def subject
      @allocation_subject = AllocationSubject.find(params.expect(:id))

      # Every academic year in which this subject has funding — powers the
      # subject page's own year filter (default: all years).
      @subject_cycles = AcademicCycle
        .joins(funding_methods: :funding_method_subjects)
        .where(funding_method_subjects: { allocation_subject_id: @allocation_subject.id })
        .distinct.order(start_date: :desc)

      redirect_to(funding_management_subject_records_path(academic_year: academic_cycle.start_year)) and return if @subject_cycles.empty?

      rows =
        if all_years?
          @subject_cycles.flat_map { |cycle| ::Funding::ReferenceQuery.new(cycle).subject_entries(@allocation_subject) }
        elsif funding_query.subject_funded?(@allocation_subject)
          funding_query.subject_entries(@allocation_subject)
        else
          redirect_to(funding_management_subject_path(@allocation_subject, academic_year: "all")) and return
        end

      @entries = Kaminari.paginate_array(apply_entry_filters(rows)).page(params[:page]).per(ENTRIES_PER_PAGE)
    end

    def entry
      @funding_method = academic_cycle.funding_methods.includes(:allocation_subjects).find_by(id: params[:id])
      redirect_to(funding_management_requirements_path(academic_year: academic_cycle.start_year)) and return if @funding_method.nil?
    end

    # Delete a single funding record (draft years only).
    def destroy_entry
      return publication_redirect(alert: "Only draft funding can be deleted.") unless can_delete_draft?

      funding_method = academic_cycle.funding_methods.find_by(id: params[:id])
      return publication_redirect(alert: "That funding record was not found for this year.") if funding_method.nil?

      reference = funding_method.reference
      funding_method.destroy!
      publication_redirect(success: "Funding record #{reference} deleted")
    end

    # Delete the funding records selected via the row tick boxes (draft only).
    def destroy_selected
      return publication_redirect(alert: "Only draft funding can be deleted.") unless can_delete_draft?

      ids = Array(params[:funding_method_ids]).compact_blank.uniq
      return publication_redirect(alert: "Select at least one funding record to delete.") if ids.empty?

      records = academic_cycle.funding_methods.where(id: ids)
      count = records.count
      records.includes(:funding_method_subjects).destroy_all
      publication_redirect(success: "Deleted #{count} funding #{'record'.pluralize(count)}")
    end

    # Confirm page: copy the previous year's funding into this empty draft year.
    def roll_over
      return publication_redirect(alert: "This academic year cannot be rolled over.") unless can_roll_over?

      @source = roll_over_source
      @source_count = @source.funding_methods.count
    end

    def create_roll_over
      return publication_redirect(alert: "This academic year cannot be rolled over.") unless can_roll_over?

      count = ::Funding::RollOverFunding.call(source: roll_over_source, target: academic_cycle)
      publication_redirect(success: "Rolled over #{count} funding #{'record'.pluralize(count)} from #{roll_over_source.label} into #{academic_cycle.label}")
    end

    # Checker (or submitter, read-only): the draft-funding review screen where a
    # colleague reviews the year's funding before approving it for release.
    def review_publication
      @publication_request = academic_cycle.pending_publication_request
      return publication_redirect(alert: "There is nothing awaiting approval for this year.") if @publication_request.nil?

      @entries = funding_query.entries
      @school_designations = FundingSchoolDesignation.includes(:school).where(academic_cycle:).joins(:school).order("schools.name")
    end

    # Checker: approve. NOTE: the different-user (four-eyes) rule is temporarily
    # relaxed — the submitter may approve their own. Re-add the
    # `request.submitted_by?(audit_user)` guard here (and in reject) to enforce it.
    def approve_publication
      request = academic_cycle.pending_publication_request
      return publication_redirect(alert: "There is nothing awaiting approval for this year.") if request.nil?

      request.update!(state: :approved, reviewed_by: audit_user, reviewed_at: Time.zone.now)
      academic_cycle.update!(published: true)
      publication_redirect(success: "#{academic_cycle.label} funding approved — ready for release")
    end

    # Checker: reject back to draft, with a reason. (Four-eyes relaxed — see approve.)
    def reject_publication
      request = academic_cycle.pending_publication_request
      return publication_redirect(alert: "There is nothing awaiting approval for this year.") if request.nil?

      request.update!(state: :rejected, reviewed_by: audit_user, reviewed_at: Time.zone.now, decision_notes: params[:decision_notes].presence)
      academic_cycle.update!(published: false)
      publication_redirect(success: "#{academic_cycle.label} funding returned to draft")
    end

    # Withdraw a pending submission back to draft.
    def withdraw_publication
      request = academic_cycle.pending_publication_request
      return publication_redirect(alert: "There is nothing awaiting approval for this year.") if request.nil?

      request.update!(state: :withdrawn, reviewed_by: audit_user, reviewed_at: Time.zone.now)
      publication_redirect(success: "#{academic_cycle.label} funding submission withdrawn")
    end

    def reports
      report = ::Funding::ReferenceReport.new(academic_cycle)

      respond_to do |format|
        format.html { @report = report }
        format.csv  { send_data(report.to_csv, filename: report.filename(:csv), type: "text/csv") }
        format.json { render(json: report.to_h) }
      end
    end

  private

    def set_academic_cycle
      @academic_cycle =
        if params[:academic_year].present?
          AcademicCycle.for_year(params[:academic_year].to_i) || default_academic_cycle
        else
          default_academic_cycle
        end
    end

    attr_reader :academic_cycle

    # The list is unscoped (all academic years) unless a specific year is chosen
    # in the filter. Blank or "all" => all years.
    def all_years?
      params[:academic_year].blank? || params[:academic_year] == "all"
    end

    # Back to the year's Requirements, or to Drafts when the action came from there.
    def publication_redirect(flash_hash)
      return drafts_redirect(flash_hash) if params[:return_to] == "drafts"

      redirect_to(funding_management_requirements_path(academic_year: academic_cycle.start_year), flash: flash_hash)
    end

    # EYTDA amounts entered for an earlier year apply to this year when it has
    # none of its own (FundingManager.eytda_funding_cycle_for). Read only, and
    # labelled for this year's starters.
    def load_carried_forward_entries
      return if academic_cycle.nil?

      source = FundingManager.eytda_funding_cycle_for(academic_cycle.start_year)
      return if source.nil? || source == academic_cycle

      rows = ::Funding::ReferenceQuery.new(source).entries
        .select { |row| row[:training_route].to_s == FundingManager::EYTDA_ROUTE }
        .map { |row| row.merge(academic_year_start: academic_cycle.start_year) }
      @carried_forward_source = source
      @carried_forward_entries = apply_entry_filters(rows)
    end

    def drafts_redirect(flash_hash)
      redirect_to(funding_management_drafts_path, flash: flash_hash)
    end

    # The most recent funded academic year before the selected one — the default
    # source for a roll over.
    def roll_over_source(cycle = academic_cycle)
      return if cycle.nil?

      AcademicCycle.joins(:funding_methods)
        .where(academic_cycles: { start_date: ...cycle.start_date })
        .distinct.order(start_date: :desc).first
    end

    # Roll over is offered only into a clean draft year with a funded predecessor.
    def can_roll_over?(cycle = academic_cycle)
      cycle.present? && cycle.draft? && !cycle.funding_methods.exists? && roll_over_source(cycle).present?
    end

    # Deleting funding is only allowed while a year is a draft (never once it is
    # awaiting approval, published, live or past).
    def can_delete_draft?(cycle = academic_cycle)
      FeatureService.enabled?("funding_management_edit") && cycle.present? && (cycle.draft? || cycle.eytda_funding_draftable?)
    end

    # Filter an entries array by the funding type / training route / degree
    # relevance query params (blank param = no filter). "none" degree relevance
    # matches rows that apply regardless of degree.
    def apply_entry_filters(rows)
      rows = rows.select { |row| row[:funding_type].to_s == params[:funding_type] } if params[:funding_type].present?
      rows = rows.select { |row| row[:training_route].to_s == params[:training_route] } if params[:training_route].present?

      if params[:degree_relevance].present?
        rows =
          if params[:degree_relevance] == "none"
            rows.select { |row| row[:degree_relevance].blank? }
          else
            rows.select { |row| row[:degree_relevance].to_s == params[:degree_relevance] }
          end
      end

      if params[:school_disadvantage].present?
        rows =
          if params[:school_disadvantage] == "none"
            rows.select { |row| row[:school_disadvantage].blank? }
          else
            rows.select { |row| row[:school_disadvantage].to_s == params[:school_disadvantage] }
          end
      end

      rows = rows.select { |row| row[:subject_id].to_s == params[:subject_id] } if params[:subject_id].present?

      rows
    end

    # Allocation subjects that have any funding, for the Subject filter — scoped
    # to the selected year unless viewing all years. Ordered by name.
    def funded_subjects
      scope = AllocationSubject.joins(funding_method_subjects: :funding_method).distinct.order(:name)
      scope = scope.where(funding_methods: { academic_cycle_id: academic_cycle.id }) unless all_years?
      scope
    end

    # Only academic years that actually have funding information.
    def academic_cycles
      @academic_cycles ||= AcademicCycle.joins(:funding_methods).distinct.order(start_date: :desc)
    end

    # Prefer the current cycle when it has funding, otherwise the most recent
    # funded cycle, falling back to the current cycle.
    def default_academic_cycle
      current = AcademicCycle.current
      return current if current&.funding_methods&.exists?

      academic_cycles.reject(&:pre_release?).first || academic_cycles.first || current
    end

    # Drafts in progress: future years not yet live (draft, awaiting approval or
    # ready for release) that have at least one funding record, soonest first.
    def in_progress_draft_cycles
      @in_progress_draft_cycles ||= AcademicCycle.where(end_date: Time.zone.today..).order(:start_date)
        .select { |cycle| (cycle.pre_release? || cycle.eytda_funding_draftable? || (cycle.eytda_only_funding_year? && cycle.awaiting_publication_approval?)) && cycle.draft_funding_methods.exists? }
    end

    # A draft year opened from Drafts (rather than the published Requirements view).
    def viewing_draft_year?
      !all_years? && academic_cycle.present? && academic_cycle.pre_release?
    end

    # Years offered in the Requirements year selector: only the draft years while
    # a draft year is open, otherwise live and past years.
    def requirement_year_cycles
      return academic_cycles.reject(&:pre_release?) unless viewing_draft_year?

      # Keep the open year listed even before its first record is added.
      in_progress_draft_cycles.include?(academic_cycle) ? in_progress_draft_cycles : [academic_cycle, *in_progress_draft_cycles].sort_by(&:start_date)
    end

    # "All academic years" on Requirements, leaving out years that are not live yet.
    def entries_outside_drafts
      draft_years = academic_cycles.select(&:pre_release?).map(&:start_year)
      ::Funding::ReferenceQuery.all_entries.reject { |row| draft_years.include?(row[:academic_year_start]) }
    end

    def funding_query
      @funding_query ||= ::Funding::ReferenceQuery.new(academic_cycle)
    end
  end
end

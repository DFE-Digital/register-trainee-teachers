# frozen_string_literal: true

module SystemAdmin
  # Funding schools management — record which schools are disadvantaged / special
  # schools for funding purposes, per academic year. Part of the Funding
  # management area; reads gated by funding_management, writes by
  # funding_management_edit.
  class FundingSchoolsController < ApplicationController
    WRITE_ACTIONS = %i[start show update check save bulk_new bulk_create destroy].freeze
    DRAFT_KEY = "funding_school_draft"
    # "Add a school" asks one question per page, then shows the school's details.
    STEPS = %w[academic_year designation school].freeze
    STEP_FIELDS = {
      "academic_year" => %i[academic_year],
      "designation" => %i[designation],
      "school" => %i[school_id school_search],
    }.freeze

    before_action { require_feature_flag(:funding_management) }
    before_action -> { require_feature_flag(:funding_management_edit) }, only: WRITE_ACTIONS
    before_action :set_academic_cycle, only: %i[index]
    before_action :set_step, only: %i[show update]

    helper_method :academic_cycle, :all_years?, :can_manage_schools?, :draft, :editing?, :previous_step

    def index
      scope = FundingSchoolDesignation.includes(:school, :academic_cycle).joins(:school)
      scope = scope.where(academic_cycle:) unless all_years?
      @designations = scope.order("schools.name")
    end

    # Start "Add a school". Keeps a year only when starting from that year's list.
    def start
      session[DRAFT_KEY] = { "academic_year" => params[:academic_year].presence }.compact
      redirect_to(funding_management_school_step_path(step: STEPS.first))
    end

    def show
      @step_form = FundingSchoolDesignationStepForm.new(draft.slice("academic_year", "designation", "school_id", "school_search").merge(step: @step))
      render(step_template)
    end

    def update
      @step_form = FundingSchoolDesignationStepForm.new(draft_answers.merge(submitted_params).merge(step: @step))

      if @step_form.valid?
        answers = submitted_params
        if @step == "school"
          # Keep the resolved school, so the check page shows its details.
          answers = { "school_id" => @step_form.school.id.to_s, "school_search" => @step_form.school.name }
        end
        session[DRAFT_KEY] = draft.merge(answers)
        redirect_to(next_screen_path)
      else
        render(step_template)
      end
    end

    # Check the school's details before adding it.
    def check
      redirect_to(funding_management_new_school_path) and return if draft.slice("academic_year", "designation", "school_id").size < 3

      @form = draft_form
      @form.valid? # shows any problem, such as the school being added since
    end

    def save
      @form = draft_form
      @form.created_by = audit_user
      if @form.save!
        session.delete(DRAFT_KEY)
        redirect_to(
          funding_management_schools_path(academic_year: @form.academic_year),
          flash: { success: "#{@form.school.name} added to the funding schools list" },
        )
      else
        render(:check)
      end
    end

    # CSV bulk upload.
    def bulk_new
      @form = FundingSchoolDesignationBulkForm.new(academic_year: default_year)
    end

    def bulk_create
      @form = FundingSchoolDesignationBulkForm.new(bulk_params.merge(created_by: audit_user))
      if @form.import!
        render(:bulk_result)
      elsif @form.errors.any?
        render(:bulk_new)
      else
        # Valid form but every row was skipped — still show the result summary.
        render(:bulk_result)
      end
    end

    def destroy
      designation = FundingSchoolDesignation.find(params[:id])
      year = designation.academic_cycle.start_year
      name = designation.school.name

      unless can_manage_schools?(designation.academic_cycle)
        redirect_to(funding_management_schools_path(academic_year: year),
                    flash: { alert: "This year's school list is locked and cannot be changed." })
        return
      end

      designation.destroy!
      redirect_to(funding_management_schools_path(academic_year: year),
                  flash: { success: "#{name} removed from the funding schools list" })
    end

  private

    def all_years?
      params[:academic_year].to_s == "all"
    end

    def set_academic_cycle
      return if all_years?

      year = params[:academic_year].presence&.to_i
      # Default to the nearest editable (future) year — the one you'd manage —
      # rather than the current live year, whose list is already locked.
      @academic_cycle = (AcademicCycle.for_year(year) if year) ||
        helpers.addable_cycles.min_by(&:start_year) ||
        AcademicCycle.current
    end

    def academic_cycle
      @academic_cycle
    end

    # Whether schools can still be managed for a cycle. Mirrors funding
    # requirements exactly: editable only while the year is a draft — once
    # submitted for approval or published, the school list is locked and is
    # approved/released together with the funding for that year.
    def can_manage_schools?(cycle)
      helpers.funding_year_editable?(cycle)
    end

    def default_year
      helpers.addable_cycles.first&.start_year
    end

    def draft
      session[DRAFT_KEY] ||= {}
    end

    def draft_answers
      draft.slice("academic_year", "designation")
    end

    def set_step
      @step = params[:step]
      redirect_to(funding_management_new_school_path) unless STEPS.include?(@step)
    end

    def step_template
      "system_admin/funding_schools/steps/#{@step}"
    end

    def editing?
      params[:from] == "check"
    end

    def submitted_params
      params.fetch(:funding_school_designation_step_form, {}).permit(*STEP_FIELDS.fetch(@step, [])).to_h
    end

    def next_screen_path
      next_step = STEPS[STEPS.index(@step) + 1]
      return funding_management_school_check_path if editing? || next_step.nil?

      funding_management_school_step_path(step: next_step)
    end

    def previous_step
      index = STEPS.index(@step)
      STEPS[index - 1] if index&.positive?
    end

    # The saved answers as the designation form (which runs every rule again).
    def draft_form
      urn = School.find_by(id: draft["school_id"])&.urn
      FundingSchoolDesignationForm.new(academic_year: draft["academic_year"], designation: draft["designation"], urn: urn)
    end

    def bulk_params
      params.fetch(:funding_school_designation_bulk_form, {}).permit(:academic_year, :designation, :file)
    end
  end
end

# frozen_string_literal: true

module SystemAdmin
  # Relevant degree CAH management — define, per academic year and ITT subject,
  # the degrees (HECoS codes under a CAH level 2) that count as a relevant degree
  # for funding. A multi-page add wizard, one question per page (academic year →
  # ITT subject → CAH level 1 → CAH level 2 → HECoS → check answers), with a
  # session-backed draft. CAH level 2 is skipped when the level 1 category has a
  # single level 2, which the wizard then sets. Management only (no evaluation
  # wiring yet). Reads gated by funding_management, writes by
  # funding_management_edit.
  class RelevantDegreesController < ApplicationController
    DRAFT_KEY = "relevant_degree_draft"
    STEPS = %w[academic_year subject cah_level_1 cah_level_2 hecos].freeze
    STEP_FIELDS = {
      "academic_year" => %i[academic_year],
      "subject" => %i[allocation_subject_id],
      "cah_level_1" => %i[cah_level_1_code],
      "cah_level_2" => %i[cah_level_2_code],
      "hecos" => [{ hecos_codes: [] }],
    }.freeze
    # Steps that asked two questions at once, before the one-question-per-page split.
    LEGACY_STEPS = { "year_subject" => "academic_year", "cah_levels" => "cah_level_1" }.freeze
    WRITE_ACTIONS = %i[start show update check create destroy].freeze

    before_action { require_feature_flag(:funding_management) }
    before_action -> { require_feature_flag(:funding_management_edit) }, only: WRITE_ACTIONS
    before_action :set_step, only: %i[show update]
    before_action :set_academic_cycle, only: %i[index]

    helper_method :academic_cycle, :all_years?, :can_manage_relevant_degrees?, :draft,
                  :wizard_previous_step, :editing?, :cah_level_2_automatic?

    def index
      scope = RelevantDegreeMapping.includes(:allocation_subject, :academic_cycle).joins(:allocation_subject)
      scope = scope.where(academic_cycle:) unless all_years?
      @mappings = scope.order("allocation_subjects.name", :cah_level_2_code, :hecos_code)
    end

    def start
      # Only keep a year the user has already chosen (by starting from that year's
      # page); otherwise nothing is preselected.
      seed = { "academic_year" => params[:academic_year].presence }.compact
      session[DRAFT_KEY] = seed
      redirect_to(funding_management_relevant_degree_step_path(step: STEPS.first))
    end

    def show
      # A page that does not apply (CAH level 2 with a single option) moves on.
      redirect_to(next_screen_path) and return unless applicable_step?(@step)

      @step_form = step_form_from_draft
      render(step_template)
    end

    def create
      @form = build_form
      @form.created_by = audit_user

      if @form.save!
        subject = AllocationSubject.find_by(id: @form.allocation_subject_id)
        year = @form.academic_year
        count = @form.created_mappings.size
        references = @form.created_mappings.map(&:reference)
        reset_draft
        redirect_to(
          funding_management_relevant_degrees_path(academic_year: year),
          flash: { success: "#{count} relevant degree #{'record'.pluralize(count)} added for #{subject&.name} (#{references.first}–#{references.last})" },
        )
      else
        render(:check)
      end
    end

    def update
      submitted = submitted_params
      @step_form = step_form(submitted)

      if @step_form.valid?
        level_1_changed = @step == "cah_level_1" && submitted[:cah_level_1_code] != draft["cah_level_1_code"]
        merge_into_draft(submitted)
        apply_cah_level_1_change if level_1_changed
        # A new level 1 needs its level 2 and HECoS codes answering again, so walk
        # the pages rather than returning straight to Check answers.
        redirect_to(next_screen_path(editing: editing? && !level_1_changed))
      else
        render(step_template)
      end
    end

    def check
      redirect_to(funding_management_new_relevant_degree_path) and return if draft["academic_year"].blank?

      @form = build_form
    end

    def destroy
      mapping = RelevantDegreeMapping.find(params.expect(:id))
      year = mapping.academic_cycle.start_year

      unless can_manage_relevant_degrees?(mapping.academic_cycle)
        redirect_to(funding_management_relevant_degrees_path(academic_year: year),
                    flash: { alert: t(".locked") })
        return
      end

      subject_name = mapping.allocation_subject.name
      mapping.destroy!
      redirect_to(funding_management_relevant_degrees_path(academic_year: year),
                  flash: { success: "Relevant degrees removed for #{subject_name} (#{mapping.cah_level_2_code})" })
    end

  private

    def all_years?
      params[:academic_year].to_s == "all"
    end

    def set_academic_cycle
      return if all_years?

      year = params[:academic_year].presence&.to_i
      @academic_cycle = (AcademicCycle.for_year(year) if year) ||
        helpers.addable_cycles.min_by(&:start_year) ||
        AcademicCycle.current
    end

    attr_reader :academic_cycle

    def can_manage_relevant_degrees?(cycle)
      helpers.funding_year_editable?(cycle)
    end

    def draft
      session[DRAFT_KEY] ||= {}
    end

    def reset_draft
      session.delete(DRAFT_KEY)
    end

    def set_step
      @step = params[:step]
      if LEGACY_STEPS.key?(@step)
        redirect_to(funding_management_relevant_degree_step_path(step: LEGACY_STEPS[@step], from: params[:from]))
      elsif !STEPS.include?(@step)
        redirect_to(funding_management_new_relevant_degree_path)
      end
    end

    # CAH level 2 is only asked when the level 1 category has more than one.
    def applicable_step?(step)
      step != "cah_level_2" || !cah_level_2_automatic?
    end

    def cah_level_2_automatic?
      ::Funding::CahReference.level_2_options(draft["cah_level_1_code"]).size == 1
    end

    # A new level 1 clears the answers that depend on it; when it has a single
    # level 2 category, the wizard chooses it.
    def apply_cah_level_1_change
      updated = draft.except("cah_level_2_code", "hecos_codes")
      only_level_2 = ::Funding::CahReference.level_2_options(updated["cah_level_1_code"])
      updated["cah_level_2_code"] = only_level_2.first.first if only_level_2.size == 1
      session[DRAFT_KEY] = updated
    end

    def step_template
      "system_admin/relevant_degrees/steps/#{@step}"
    end

    def editing?
      params[:from] == "check"
    end

    def step_form_from_draft
      form = RelevantDegreeStepForm.new(draft.slice(*step_attribute_names))
      form.step = @step
      form
    end

    def step_form(submitted)
      form = RelevantDegreeStepForm.new(draft.slice(*step_attribute_names).merge(submitted.stringify_keys))
      form.step = @step
      form
    end

    def step_attribute_names
      %w[academic_year allocation_subject_id cah_level_1_code cah_level_2_code hecos_codes]
    end

    def submitted_params
      params.fetch(:relevant_degree_step_form, {}).permit(*STEP_FIELDS.fetch(@step, [])).to_h
    end

    def merge_into_draft(submitted)
      session[DRAFT_KEY] = draft.merge(submitted.stringify_keys)
    end

    def next_screen_path(editing: editing?)
      return funding_management_relevant_degree_check_path if editing

      index = STEPS.index(@step)
      next_step = index && STEPS[(index + 1)..].find { |step| applicable_step?(step) }
      next_step ? funding_management_relevant_degree_step_path(step: next_step) : funding_management_relevant_degree_check_path
    end

    def wizard_previous_step
      index = STEPS.index(@step)
      index && STEPS[0...index].rfind { |step| applicable_step?(step) }
    end

    def build_form
      RelevantDegreeMappingForm.new(draft.slice(*step_attribute_names))
    end
  end
end

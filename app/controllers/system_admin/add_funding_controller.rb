# frozen_string_literal: true

module SystemAdmin
  # The "Add funding" multi-page journey (GOV.UK wizard) for Funding management.
  # One question per page, answers held in a session draft, ending at Check your
  # answers → create. Writing is gated by funding_management_edit.
  class AddFundingController < ApplicationController
    before_action { require_feature_flag(:funding_management) }
    before_action { require_feature_flag(:funding_management_edit) }
    before_action :set_step, only: %i[show update]

    DRAFT_KEY = "add_funding_draft"

    # Params permitted from the step form, per step.
    STEP_FIELDS = {
      "academic_year" => %i[academic_year],
      "funding_type" => %i[funding_type],
      "funding_method" => %i[funding_method],
      "financial_incentives" => %i[financial_incentives],
      "education_phase" => %i[education_phase],
      "exception" => %i[student_finance_exception],
      "training_routes" => [{ training_routes: [] }],
      "amount" => %i[amount amount_relevant amount_unrelated amount_unrelated_available amount_disadvantaged amount_non_disadvantaged
                     amount_tier_one amount_tier_two amount_tier_three
                     amount_year_1 amount_year_2 amount_year_3 amount_year_4],
      "subjects" => [{ allocation_subject_ids: [] }],
    }.freeze

    helper_method :draft, :editing?, :route_applicability

    def start
      # No funding type is pre-selected, so a grant or scholarship is chosen deliberately.
      seed = { "academic_year" => params[:academic_year].presence }.compact
      session[DRAFT_KEY] = seed
      redirect_to(funding_management_add_step_path(step: Wizards::AddFundingWizard.first_step))
    end

    def show
      # A conditional step reached directly (or after an earlier answer changed)
      # that no longer applies — walk on to the next applicable screen.
      unless Wizards::AddFundingWizard.applicable_step?(@step, draft)
        redirect_to(next_screen_path) and return
      end

      @step_form = step_form_from_draft
      render(step_template)
    end

    def update
      submitted = submitted_params
      # On the training-routes step, drop any route that the earlier answers make
      # non-applicable (defends against a hand-crafted post; the UI greys them out).
      if @step == "training_routes" && submitted.key?(:training_routes)
        submitted[:training_routes] = route_applicability.filter(submitted[:training_routes])
      end

      # "Not available" for an unrelated degree has no amount.
      submitted["amount_unrelated"] = nil if submitted["amount_unrelated_available"].to_s == "no"
      @step_form = step_form(submitted)

      if @step_form.valid?
        tiered_before = Wizards::AddFundingWizard.early_years_tiered?(draft)
        early_years_before = early_years_subject_automatic?
        early_years_routes_before = Wizards::AddFundingWizard.early_years_routes?(draft)
        amount_keys_before = amount_keys
        funding_type_before = draft["funding_type"]
        merge_into_draft(submitted)
        apply_funding_method_answers if @step == "funding_type"
        apply_early_years_tiered_answers(tiered_before) if %w[funding_type funding_method].include?(@step)
        apply_early_years_route_answers(early_years_routes_before)
        apply_early_years_subject(early_years_before)
        steps_changed = funding_type_before != draft["funding_type"] ||
          tiered_before != Wizards::AddFundingWizard.early_years_tiered?(draft) ||
          early_years_before != early_years_subject_automatic? ||
          early_years_routes_before != Wizards::AddFundingWizard.early_years_routes?(draft) ||
          amount_keys_before != amount_keys
        # Switching to or from the tiered bursary or an early years route, or a
        # change to which amounts are needed, alters the later steps, so walk them
        # instead of returning to Check answers.
        redirect_to(next_screen_path(editing: editing? && !steps_changed))
      else
        render(step_template)
      end
    end

    def check
      redirect_to(funding_management_add_start_path) and return if draft["academic_year"].blank?

      @form = build_funding_method_form
    end

    def create
      @form = build_funding_method_form

      if @form.save!
        count = @form.created_funding_methods.size
        reset_draft
        redirect_to(
          funding_management_requirements_path(academic_year: @form.academic_year),
          flash: { success: "Funding added — #{count} funding #{'record'.pluralize(count)} created" },
        )
      else
        render(:check)
      end
    end

  private

    def draft
      session[DRAFT_KEY] ||= {}
    end

    # Route greying for the training-routes step, derived from earlier answers.
    def route_applicability
      @route_applicability ||= ::Funding::RouteApplicability.new(
        funding_type: draft["funding_type"],
        funding_method: draft["funding_method"],
      )
    end

    def reset_draft
      session.delete(DRAFT_KEY)
    end

    def set_step
      @step = params[:step]
      redirect_to(funding_management_add_start_path) unless Wizards::AddFundingWizard.valid_step?(@step)
    end

    def step_template
      "system_admin/add_funding/steps/#{@step}"
    end

    def editing?
      params[:from] == "check"
    end

    # A step form pre-filled from the draft (for GET show / re-render).
    def step_form_from_draft
      form = AddFundingStepForm.new(draft.slice(*step_form_attribute_names))
      form.step = @step
      form
    end

    # A step form built from the draft plus the just-submitted answer.
    def step_form(submitted)
      # The amount step needs the chosen Financial Incentive criterion (answered
      # earlier) to know which amount boxes to validate.
      attrs = draft.slice("academic_year", "financial_incentives", "funding_method", "funding_type", "training_routes").merge(submitted.stringify_keys)
      form = AddFundingStepForm.new(attrs.slice(*step_form_attribute_names))
      form.step = @step
      form
    end

    def step_form_attribute_names
      %w[academic_year funding_type funding_method financial_incentives
         education_phase student_finance_exception training_routes
         amount amount_relevant amount_unrelated amount_unrelated_available amount_disadvantaged amount_non_disadvantaged
         amount_tier_one amount_tier_two amount_tier_three
         amount_year_1 amount_year_2 amount_year_3 amount_year_4
         allocation_subject_ids]
    end

    def submitted_params
      params.fetch(AddFundingStepForm.model_name.param_key, {}).permit(*STEP_FIELDS.fetch(@step, [])).to_h
    end

    def merge_into_draft(submitted)
      session[DRAFT_KEY] = draft.merge(submitted.stringify_keys)
    end

    # Grants and scholarships have one funding method, set here (the question is
    # skipped). Moving to a bursary clears a non-bursary method so its type is asked.
    def apply_funding_method_answers
      answers = Wizards::AddFundingWizard.funding_method_answers(draft["funding_type"])
      if answers
        session[DRAFT_KEY] = draft.merge(answers)
      elsif Wizards::AddFundingWizard::FUNDING_METHOD_BY_TYPE.value?(draft["funding_method"])
        session[DRAFT_KEY] = draft.except("funding_method")
      end
    end

    # The Early years tiered bursary sets its route and Financial Incentive answer
    # itself; moving away from it clears those and the tier amounts.
    def apply_early_years_tiered_answers(tiered_before)
      if Wizards::AddFundingWizard.early_years_tiered?(draft)
        session[DRAFT_KEY] = draft.merge(Wizards::AddFundingWizard.early_years_tiered_answers)
      elsif tiered_before
        session[DRAFT_KEY] = draft.except("financial_incentives", "training_routes", *::Funding::AmountMatrix::TIER_KEYS.map(&:to_s))
      end
    end

    # The amount boxes the current answers need (to spot when a change needs new amounts).
    def amount_keys
      ::Funding::AmountMatrix.for(
        financial_incentive: draft["financial_incentives"], funding_method: draft["funding_method"],
        training_routes: draft["training_routes"], start_year: draft["academic_year"]
      ).map(&:key)
    end

    def early_years_subject_automatic?
      ::Funding::EligibleSubjects.automatic?(draft["training_routes"])
    end

    # Early years routes only fund Early years ITT, so the wizard sets it (and
    # skips the subjects step). Moving away from early years routes clears it.
    # Early years routes skip the Financial Incentive criteria and education phase
    # steps, so the wizard answers them. Moving away from early years routes clears
    # those answers so they are asked.
    def apply_early_years_route_answers(early_years_routes_before)
      if Wizards::AddFundingWizard.early_years_routes?(draft)
        session[DRAFT_KEY] = draft.merge(Wizards::AddFundingWizard.early_years_route_answers)
      elsif early_years_routes_before
        session[DRAFT_KEY] = draft.except(*Wizards::AddFundingWizard.early_years_route_answers.keys)
      end
    end

    def apply_early_years_subject(early_years_before)
      if early_years_subject_automatic?
        session[DRAFT_KEY] = draft.merge("allocation_subject_ids" => [::Funding::EligibleSubjects.early_years_subject.id.to_s])
      elsif early_years_before
        session[DRAFT_KEY] = draft.except("allocation_subject_ids")
      end
    end

    def next_screen_path(editing: editing?)
      wizard = Wizards::AddFundingWizard.new(@step, editing:, draft:)
      next_step = wizard.next_step

      if next_step == Wizards::AddFundingWizard::CHECK_ANSWERS
        funding_management_add_check_path
      else
        funding_management_add_step_path(step: next_step)
      end
    end

    def build_funding_method_form
      FundingMethodForm.new(draft.slice(*funding_method_form_attribute_names))
    end

    def funding_method_form_attribute_names
      %w[academic_year funding_type funding_method financial_incentives
         education_phase student_finance_exception training_routes
         amount amount_relevant amount_unrelated amount_unrelated_available amount_disadvantaged amount_non_disadvantaged
         amount_tier_one amount_tier_two amount_tier_three
         amount_year_1 amount_year_2 amount_year_3 amount_year_4
         allocation_subject_ids]
    end
  end
end

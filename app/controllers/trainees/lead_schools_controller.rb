# frozen_string_literal: true

module Trainees
  class LeadSchoolsController < BaseController
    before_action :validate_form_completeness

    helper_method :query

    def index
      @lead_partner_form = Partners::LeadPartnerForm.new(trainee)
      @lead_partner_search = LeadPartnerSearch.call(query:)
    end

    def edit
      @lead_partner_form = Partners::LeadPartnerForm.new(trainee)
    end

    def update
      @lead_partner_form = Partners::LeadPartnerForm.new(trainee, params: trainee_params, user: current_user)

      if @lead_partner_form.lead_partner_not_selected? && @lead_partner_form.valid?
        return redirect_to(trainee_lead_schools_path(@trainee, query:))
      end

      if @lead_partner_form.stash_or_save!
        redirect_to(step_wizard.next_step)
      else
        @lead_partner_search = LeadPartnerSearch.call(query: params[:query])
        render(index_or_edit_page)
      end
    end

  private

    def trainee_params
      params.fetch(:partners_lead_partner_form, {})
            .permit(*Partners::LeadPartnerForm::FIELDS,
                    *Partners::LeadPartnerForm::NON_TRAINEE_FIELDS)
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      @lead_partner_form.search_results_found? || @lead_partner_form.no_results_searching_again? ? :index : :edit
    end

    def authorize_trainee
      authorize(trainee, :requires_schools?)
    end

    def step_wizard
      @step_wizard ||= Wizards::SchoolsStepWizard.new(trainee:, page_tracker:)
    end

    def validate_form_completeness
      return if trainee.lead_partner_id.blank?
      return if user_came_from_backlink?

      redirect_to(step_wizard.start_point) if step_wizard.start_point.present?
    end
  end
end

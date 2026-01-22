# frozen_string_literal: true

module Trainees
  class TrainingPartnersController < BaseController
    before_action :training_partner_applicable
    before_action :validate_form_completeness

    helper_method :query

    def index
      @training_partner_search = TrainingPartnerSearch.call(query:)
    end

    def update
      if @training_partner_form.training_partner_not_selected? && @training_partner_form.valid?
        return redirect_to(trainee_training_partners_path(@trainee, query:))
      end

      if @training_partner_form.stash_or_save!
        redirect_to(step_wizard.next_step)
      else
        @training_partner_search = TrainingPartnerSearch.call(query: params[:query])
        render(index_or_edit_page)
      end
    end

  private

    def trainee_params
      params.fetch(:partners_training_partner_form, {})
            .permit(:training_partner_id,
                    *Partners::TrainingPartnerForm::NON_TRAINEE_FIELDS)
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      @training_partner_form.search_results_found? || @training_partner_form.no_results_searching_again? ? :index : :edit
    end

    def training_partner_form
      @training_partner_form ||= Partners::TrainingPartnerForm.new(
        trainee,
        params: trainee_params,
        user: current_user,
      )
    end

    def training_partner_applicable
      if training_partner_form.training_partner_not_applicable?
        redirect_to(edit_trainee_training_partners_details_path(trainee))
      end
    end

    def authorize_trainee
      authorize(trainee, :requires_training_partner?)
    end

    def step_wizard
      @step_wizard ||= Wizards::SchoolsStepWizard.new(trainee:, page_tracker:)
    end

    def validate_form_completeness
      return if trainee.training_partner_id.blank?
      return if user_came_from_backlink?

      redirect_to(step_wizard.start_point) if step_wizard.start_point.present?
    end
  end
end

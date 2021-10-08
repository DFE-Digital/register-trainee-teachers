# frozen_string_literal: true

module Trainees
  class LeadSchoolsController < ApplicationController
    before_action :authorize_trainee, :validate_form_completeness

    helper_method :query

    def index
      @lead_school_form = Schools::LeadSchoolForm.new(trainee)
      @school_search = SchoolSearch.call(query: query, lead_schools_only: true)
    end

    def edit
      @lead_school_form = Schools::LeadSchoolForm.new(trainee)
    end

    def update
      @lead_school_form = Schools::LeadSchoolForm.new(trainee, params: trainee_params, user: current_user)

      if @lead_school_form.school_not_selected? && @lead_school_form.valid?
        return redirect_to(trainee_lead_schools_path(@trainee, query: query))
      end

      save_strategy = trainee.draft? ? :save! : :stash

      if @lead_school_form.public_send(save_strategy)
        redirect_to(step_wizard.next_step)
      else
        @school_search = SchoolSearch.call(query: params[:query], lead_schools_only: true)
        render(index_or_edit_page)
      end
    end

  private

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.fetch(:schools_lead_school_form, {}).permit(:lead_school_id, *Schools::LeadSchoolForm::NON_TRAINEE_FIELDS)
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      @lead_school_form.search_results_found? || @lead_school_form.no_results_searching_again? ? :index : :edit
    end

    def authorize_trainee
      authorize(trainee, :requires_schools?)
    end

    def step_wizard
      @step_wizard ||= Wizards::SchoolsStepWizard.new(trainee: trainee, page_tracker: page_tracker)
    end

    def validate_form_completeness
      return if trainee.lead_school_id.blank?
      return if user_came_from_backlink?

      redirect_to(step_wizard.start_point) if step_wizard.start_point.present?
    end
  end
end

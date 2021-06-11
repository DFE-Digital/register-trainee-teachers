# frozen_string_literal: true

module Trainees
  class LeadSchoolsController < ApplicationController
    before_action :authorize_trainee
    before_action :load_schools

    helper_method :query

    def index
      school_search
      @lead_school_form = Schools::LeadSchoolForm.new(trainee)
    end

    def edit
      @lead_school_form = Schools::LeadSchoolForm.new(trainee)
    end

    def update
      @lead_school_form = Schools::LeadSchoolForm.new(trainee, params: trainee_params, user: current_user)

      if @lead_school_form.school_not_selected? && @lead_school_form.valid?
        return redirect_to trainee_lead_schools_path(@trainee, query: query)
      end

      save_strategy = trainee.draft? ? :save! : :stash

      if @lead_school_form.public_send(save_strategy)
        redirect_to origin_page_or_next_step
      else
        render index_or_edit_page
      end
    end

  private

    def redirect_url
      trainee.requires_employing_school? ? edit_trainee_employing_schools_path(trainee) : trainee_schools_confirm_path(trainee)
    end

    def load_schools
      @schools = school_search_service.specified_schools
    end

    def school_search
      @school_search = school_search_service.call
    end

    def school_search_service
      SchoolSearch.call(query: query, lead_schools_only: true)
    end

    def trainee
      @trainee ||= Trainee.from_param(params[:trainee_id])
    end

    def trainee_params
      params.fetch(:schools_lead_school_form, {}).permit(:lead_school_id, *Schools::LeadSchoolForm::NON_TRAINEE_FIELDS)
    end

    def origin_page_or_next_step
      return trainee_schools_confirm_path if user_come_from_confirm_or_trainee_page?

      redirect_url
    end

    def user_come_from_confirm_or_trainee_page?
      page_tracker.last_origin_page_path&.include?("schools/confirm") || page_tracker.last_origin_page_path == "/trainees/#{trainee.slug}"
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      @lead_school_form.index_page_radio_buttons? ? :index : :edit
    end

    def authorize_trainee
      authorize(trainee, :requires_schools?)
    end
  end
end

# frozen_string_literal: true

module Trainees
  class EmployingSchoolsController < BaseController
    before_action :employing_school_applicable
    before_action :load_schools

    helper_method :query

    def edit
      render(:assessment_only) if trainee.requires_assessment_only_employing_school?
    end

    def update
      if redirect_to_search_results?
        return redirect_to(trainee_employing_schools_path(@trainee, query:))
      end

      if @employing_school_form.stash_or_save!
        redirect_to(trainee_schools_confirm_path(trainee))
      else
        render(index_or_edit_page)
      end
    end

  private

    def redirect_to_search_results?
      if trainee.requires_assessment_only_employing_school?
        @employing_school_form.needs_search_results?
      else
        @employing_school_form.school_not_selected? && @employing_school_form.valid?
      end
    end

    def load_schools
      @school_search = SchoolSearch.call(query:)
    end

    def trainee_params
      permitted = [:employing_school_id, *form_klass::NON_TRAINEE_FIELDS]
      if trainee.requires_assessment_only_employing_school?
        permitted.push(:employing_school_name, :employing_school_urn, :employing_school_postcode)
      end

      params.fetch(form_param_key, {}).permit(*permitted)
    end

    def form_param_key
      if trainee.requires_assessment_only_employing_school?
        :schools_assessment_only_employing_school_form
      else
        :schools_employing_school_form
      end
    end

    def form_klass
      if trainee.requires_assessment_only_employing_school?
        Schools::AssessmentOnlyEmployingSchoolForm
      else
        Schools::EmployingSchoolForm
      end
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      if @employing_school_form.search_results_found? || @employing_school_form.no_results_searching_again?
        :index
      elsif trainee.requires_assessment_only_employing_school?
        :assessment_only
      else
        :edit
      end
    end

    def employing_school_form
      @employing_school_form ||= form_klass.new(
        trainee,
        params: trainee_params,
        user: current_user,
      )
    end

    def employing_school_applicable
      employing_school_form
      return if trainee.requires_assessment_only_employing_school?
      return unless @employing_school_form.school_not_applicable?

      redirect_to(edit_trainee_employing_schools_details_path(trainee))
    end

    def authorize_trainee
      if trainee.requires_assessment_only_employing_school?
        authorize(trainee, :requires_assessment_only_employing_school?)
      else
        authorize(trainee, :requires_employing_school?)
      end
    end
  end
end

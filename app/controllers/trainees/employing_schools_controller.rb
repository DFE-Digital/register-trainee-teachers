# frozen_string_literal: true

module Trainees
  class EmployingSchoolsController < BaseController
    before_action :employing_school_applicable
    before_action :load_schools

    helper_method :query

    def update
      if @employing_school_form.school_not_selected? && @employing_school_form.valid?
        return redirect_to(trainee_employing_schools_path(@trainee, query:))
      end

      if @employing_school_form.stash_or_save!
        redirect_to(trainee_schools_confirm_path(trainee))
      else
        render(index_or_edit_page)
      end
    end

  private

    def load_schools
      @school_search = SchoolSearch.call(query:)
    end

    def trainee_params
      params.fetch(:schools_employing_school_form, {})
            .permit(:employing_school_id,
                    *Schools::EmployingSchoolForm::NON_TRAINEE_FIELDS)
    end

    def query
      # Order important here including the use of presence() on the first hash lookup to ensure that if the user
      # submits the form with results but hasn't made a choice, we re-render the page with the previous results
      # including a validation message. Even though the search again field is hidden in this scenario, it will be
      # included in the form data, therefore we have to take that into account.
      trainee_params[:results_search_again_query].presence || trainee_params[:no_results_search_again_query] || trainee_params[:query] || params[:query]
    end

    def index_or_edit_page
      @employing_school_form.search_results_found? || @employing_school_form.no_results_searching_again? ? :index : :edit
    end

    def employing_school_form
      @employing_school_form ||= Schools::EmployingSchoolForm.new(
        trainee,
        params: trainee_params,
        user: current_user,
      )
    end

    def employing_school_applicable
      if employing_school_form.school_not_applicable?
        redirect_to(edit_trainee_employing_schools_details_path(trainee))
      end
    end

    def authorize_trainee
      authorize(trainee, :requires_employing_school?)
    end
  end
end

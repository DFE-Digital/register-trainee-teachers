# frozen_string_literal: true

class TraineesController < BaseTraineeController
  include TraineeHelper
  include ActivityTracker

  before_action :redirect_to_not_found, if: -> { trainee.discarded? }, only: :show
  before_action :ensure_trainee_is_not_draft!, :load_missing_data_view, only: :show
  before_action :clear_page_tracker, only: :show

  def show
    authorize(trainee)
    clear_form_stash(trainee)
    page_tracker.save_as_origin!
    @timeline_events = Trainees::CreateTimeline.call(trainee:, current_user:)
  end

  def new
    skip_authorization
    @trainee = Trainee.new
  end

  def create
    provider_id = current_user.provider? ? current_user.organisation.id : nil
    authorize(@trainee = Trainee.new(trainee_params.merge(provider_id:)))
    trainee.set_early_years_course_details

    if trainee.save
      redirect_to(trainee_review_drafts_path(trainee))
    else
      render(:new)
    end
  end

  def destroy
    authorize(trainee)
    trainee.draft? ? trainee.destroy! : trainee.discard!
    flash[:success] = t("views.trainees.delete.#{trainee.draft? ? :draft : :record}")
    redirect_to(trainee.draft? ? drafts_path : trainees_path)
  end

private

  def search_path(filter_params = nil)
    trainees_path(filter_params)
  end

  def search_primary_result_title
    @search_primary_result_title ||= t("views.trainees.index.results.above_the_fold_title")
  end

  def search_primary_result_set
    []
  end

  def search_secondary_result_title
    @search_secondary_result_title ||= t("views.trainees.index.results.below_the_fold_title")
  end

  def search_secondary_result_set
    paginated_trainees.reject(&:draft?)
  end

  def trainee_search_scope
    Trainee.includes({ provider: [:courses] }, :start_academic_cycle, :apply_application, :end_academic_cycle).not_draft
  end

  def export_results_path
    trainees_path(filter_params.merge(format: "csv"))
  end

  def redirect_to_not_found
    redirect_to(not_found_path)
  end

  def permitted_params
    [
      :subject,
      :text_search,
      :start_year,
      :end_year,
      :sort_by,
      {
        academic_year: [],
        level: [],
        training_route: [],
        status: [],
        record_source: [],
        record_completion: [],
        study_mode: [],
      },
    ]
  end

  def load_missing_data_view
    return unless trainee_editable?

    @missing_data_view = MissingDataBannerView.new(missing_fields, trainee)
  end

  def missing_fields
    @missing_fields ||= Submissions::MissingDataValidator.new(trainee:).missing_fields
  end

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def trainee_params
    params.fetch(:trainee, {}).permit(:training_route, :record_source)
  end

  def clear_page_tracker
    page_tracker.clear_redundant_session_data
  end
end

# frozen_string_literal: true

class TraineesController < BaseTraineeController
  include TraineeHelper
  include ActivityTracker

  before_action :redirect_to_not_found, if: -> { trainee.discarded? }, only: :show
  before_action :ensure_trainee_is_not_draft!, :load_missing_data_view, only: :show

  def show
    authorize(trainee)
    clear_form_stash(trainee)
    page_tracker.save_as_origin!
    render(layout: "trainee_record")
  end

  def new
    skip_authorization
    @trainee = Trainee.new
  end

  def create
    if trainee_params[:training_route] == "other"
      redirect_to(trainees_not_supported_route_path)
    else
      authorize(@trainee = Trainee.new(trainee_params.merge(provider_id: current_user.provider_id)))
      trainee.set_early_years_course_details
      if trainee.save
        redirect_to(trainee_review_drafts_path(trainee))
      else
        render(:new)
      end
    end
  end

  def destroy
    authorize(trainee)
    trainee.draft? ? trainee.destroy! : trainee.discard!
    flash[:success] = t("views.trainees.delete.#{trainee.draft? ? :draft : :record}")
    redirect_to(trainees_path)
  end

private

  def search_path(filter_params = nil)
    trainees_path(filter_params)
  end

  def search_primary_result_title
    @search_primary_result_title ||= t("views.trainees.index.results.above_the_fold_title")
  end

  def search_primary_result_set
    # We can't use `#draft` to find @draft_trainees since that applies a `WHERE`
    # clause, removing Kaminari's pagination. Hence the use of `#select`.
    paginated_trainees.select(&:draft?)
  end

  def search_secondary_result_title
    @search_secondary_result_title ||= t("views.trainees.index.results.below_the_fold_title")
  end

  def search_secondary_result_set
    paginated_trainees.reject(&:draft?)
  end

  def trainee_search_scope
    Trainee.includes(provider: [:courses])
  end

  def export_results_path
    trainees_path(filter_params.merge(format: "csv"))
  end

  def redirect_to_not_found
    redirect_to(not_found_path)
  end

  def load_missing_data_view
    @missing_data_view = MissingDataBannerView.new(missing_fields, trainee)
  end

  def missing_fields
    @missing_fields ||= Submissions::MissingDataValidator.new(trainee: trainee).missing_fields
  end

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def ordered_trainees
    policy_scope(Trainee.includes(provider: [:courses]).ordered_by_drafts_then_by(field))
  end

  def trainee_params
    params.fetch(:trainee, {}).permit(:training_route)
  end
end

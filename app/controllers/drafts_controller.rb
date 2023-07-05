# frozen_string_literal: true

class DraftsController < BaseTraineeController
  include TraineeHelper
  include ActivityTracker

  def index
    authorize(current_user, :drafts?)
    super
  end

private

  def search_path(filter_params = nil)
    drafts_path(filter_params)
  end

  def search_primary_result_title
    @search_primary_result_title ||= t("views.drafts.index.results.above_the_fold_title")
  end

  def search_primary_result_set
    paginated_trainees.select(&:submission_ready?)
  end

  def search_secondary_result_title
    @search_secondary_result_title ||= t("views.drafts.index.results.below_the_fold_title")
  end

  def search_secondary_result_set
    paginated_trainees.reject(&:submission_ready?)
  end

  def trainee_search_scope
    Trainee.draft.includes(:start_academic_cycle, :end_academic_cycle, :apply_application, provider: [:courses])
  end

  def export_results_path
    drafts_path(filter_params.merge(format: "csv"))
  end
end

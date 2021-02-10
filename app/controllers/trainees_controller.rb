# frozen_string_literal: true

class TraineesController < ApplicationController
  before_action :ensure_trainee_is_not_draft!, only: :show
  helper_method :filter_params

  def index
    return redirect_to trainees_path(filter_params) if current_page_exceeds_total_pages?

    # We can't use `#draft` to find @draft_trainees since that applies a `WHERE`
    # clause, removing Kaminari's pagination. Hence the use of `#select`.
    #
    # Conversely, we need to call Kaminari's `#total_count` on the ActiveRecord
    # Relations for the pre-pagination count. Hence the secondary call to `#draft`.
    @draft_trainees = paginated_trainees.select(&:draft?)
    @draft_trainees_count = filtered_trainees.draft.count

    @completed_trainees = paginated_trainees.reject(&:draft?)
    @completed_trainees_count = filtered_trainees.not_draft.count

    respond_to do |format|
      format.html
      format.csv { send_data data_export.data, filename: data_export.filename, disposition: :attachment }
    end
  end

  def show
    authorize trainee
    page_tracker.save_as_origin!
    render layout: "trainee_record"
  end

  def new
    skip_authorization
    @trainee = Trainee.new
  end

  def create
    if trainee_params[:record_type] == "other"
      redirect_to trainees_not_supported_route_path
    else
      authorize @trainee = Trainee.new(trainee_params.merge(provider_id: current_user.provider_id))
      if trainee.save
        redirect_to review_draft_trainee_path(trainee)
      else
        render :new
      end
    end
  end

  def update
    authorize trainee
    trainee.update!(trainee_params)
    redirect_to page_tracker.last_origin_page_path
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def current_page_exceeds_total_pages?
    paginated_trainees.total_pages.nonzero? && paginated_trainees.current_page > paginated_trainees.total_pages
  end

  def paginated_trainees
    @paginated_trainees ||= filtered_trainees.page(params[:page] || 1)
  end

  def filtered_trainees
    @filtered_trainees ||= Trainees::Filter.call(
      trainees: ordered_trainees,
      filters: filters,
    )
  end

  def ordered_trainees
    sort_scope = filter_params[:sort_by] == "last_name" ? :ordered_by_last_name : :ordered_by_date
    policy_scope(Trainee.ordered_by_drafts.public_send(sort_scope))
  end

  def filters
    @filters ||= TraineeFilter.new(params: filter_params).filters
  end

  def trainee_params
    params.fetch(:trainee, {}).permit(:record_type)
  end

  def filter_params
    params.permit(:subject, :text_search, :sort_by, record_type: [], state: [])
  end

  def data_export
    @data_export ||= Exports::TraineeSearchData.new(filtered_trainees)
  end
end

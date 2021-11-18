# frozen_string_literal: true

class TraineesController < ApplicationController
  include TraineeHelper
  include ActivityTracker

  before_action :ensure_trainee_is_not_draft!, :load_missing_data_view, only: :show
  before_action :save_filter, only: :index
  helper_method :filter_params, :multiple_record_sources?

  def index
    return redirect_to(trainees_path(filter_params)) if current_page_exceeds_total_pages?

    @total_trainees_count = filtered_trainees.count(:id)

    # We can't use `#draft` to find @draft_trainees since that applies a `WHERE`
    # clause, removing Kaminari's pagination. Hence the use of `#select`.
    @draft_trainees = paginated_trainees.select(&:draft?)
    @completed_trainees = paginated_trainees.reject(&:draft?)

    # sort_by is to enable alphabetization in line with translations, which is named different to the hash.
    @training_routes = policy_scope(Trainee).group(:training_route)
                                            .count
                                            .keys
                                            .sort_by(&TRAINING_ROUTE_ENUMS.values.method(:index))

    @providers = Provider.all.order(:name)

    respond_to do |format|
      format.html
      format.js { render(json: json_response) }
      format.csv do
        track_activity
        send_data(data_export.data, filename: data_export.filename, disposition: :attachment)
      end
    end
  end

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

  def load_missing_data_view
    @missing_data_view = MissingDataBannerView.new(
      Submissions::MissingDataValidator.new(trainee: trainee).missing_fields, trainee
    )
  end

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def current_page_exceeds_total_pages?
    paginated_trainees.total_pages.nonzero? && paginated_trainees.current_page > paginated_trainees.total_pages
  end

  def filtered_trainees
    @filtered_trainees ||= Trainees::Filter.call(
      trainees: policy_scope(Trainee.includes(provider: [:courses])),
      filters: filters,
    )
  end

  def field
    @field ||= filter_params[:sort_by] == "last_name" ? :last_name : :updated_at
  end

  def ordered_trainees
    policy_scope(Trainee.includes(provider: [:courses]).ordered_by_drafts_then_by(field))
  end

  def paginated_trainees
    @paginated_trainees ||= filtered_trainees.ordered_by_drafts_then_by(field).page(params[:page] || 1)
  end

  def filters
    @filters ||= TraineeFilter.new(params: filter_params).filters
  end

  def trainee_params
    params.fetch(:trainee, {}).permit(:training_route)
  end

  def filter_params
    params.permit(permitted_params + permitted_admin_params)
  end

  def permitted_admin_params
    return [] unless current_user.system_admin?

    [:provider]
  end

  def permitted_params
    [
      :subject,
      :text_search,
      :sort_by, {
        level: [],
        training_route: [],
        state: [],
        record_source: [],
        record_completion: [],
      }
    ]
  end

  def multiple_record_sources?
    @multiple_record_sources ||= begin
      apply_count = policy_scope(Trainee).with_apply_application.count
      manual_count = policy_scope(Trainee).with_manual_application.count
      apply_count.positive? && manual_count.positive?
    end
  end

  def save_filter
    return if request.format.csv?

    FilteredBackLink::Tracker.new(session: session, href: trainees_path).save_path(request.fullpath)
  end

  def data_export
    @data_export ||= Exports::TraineeSearchData.new(filtered_trainees)
  end

  def json_response
    {
      results: render_partial("trainees/results", {
        paginated_trainees: @paginated_trainees,
        draft_trainees: @draft_trainees,
        completed_trainees: @completed_trainees,
        filters: @filters,
      }),
      selected_filters: render_partial("trainees/selected_filters", {
        filters: @filters,
      }),
      action_bar: render_partial("trainees/action_bar", {
        paginated_trainees: @paginated_trainees,
      }),
      trainee_count: @total_trainees_count,
      page_title: trainees_page_title(@paginated_trainees, @total_trainees_count),
    }
  end

  def render_partial(partial, locals)
    (render_to_string(formats: %w[html], partial: partial, locals: locals) || "").squish
  end
end

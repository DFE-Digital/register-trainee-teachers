# frozen_string_literal: true

class BaseTraineeController < ApplicationController
  HELPER_METHODS = %i[
    export_results_path
    filter_params
    filters
    available_record_sources
    show_source_filters?
    paginated_trainees
    providers
    search_primary_result_set
    search_primary_result_title
    search_secondary_result_set
    search_secondary_result_title
    total_trainees_count
    training_routes
  ].freeze

  before_action :save_filter, only: :index

  helper_method(*HELPER_METHODS)

  def index
    return redirect_to(search_path(filter_params)) if current_page_exceeds_total_pages?

    respond_to do |format|
      format.html
      format.js { render(json: json_response) }
      format.csv do
        authorize(:trainee, :export?)
        track_activity
        send_data(data_export.data, filename: data_export.filename, disposition: :attachment)
      end
    end
  end

private

  def search_path
    raise(NotImplementedError)
  end

  def search_primary_result_title
    raise(NotImplementedError)
  end

  def search_primary_result_set
    raise(NotImplementedError)
  end

  def search_secondary_result_title
    raise(NotImplementedError)
  end

  def search_secondary_result_set
    raise(NotImplementedError)
  end

  def trainee_search_scope
    raise(NotImplementedError)
  end

  def export_results_path
    raise(NotImplementedError)
  end

  def total_trainees_count
    filtered_trainees.count
  end

  def providers
    @providers ||= Provider.all.order(:name)
  end

  def training_routes
    policy_scope(Trainee)
      .group(:training_route)
      .count
      .keys
      .sort_by(&TRAINING_ROUTE_ENUMS.values.method(:index))
  end

  def current_page_exceeds_total_pages?
    paginated_trainees.total_pages.nonzero? && paginated_trainees.current_page > paginated_trainees.total_pages
  end

  def filtered_trainees
    @filtered_trainees ||= Trainees::Filter.call(
      trainees: policy_scope(trainee_search_scope),
      filters: filters,
    )
  end

  def field
    @field ||= filter_params[:sort_by] == "last_name" ? :last_name : :updated_at
  end

  def paginated_trainees
    @paginated_trainees ||= filtered_trainees.public_send("ordered_by_#{field}")
                                             .page(params[:page] || 1)
  end

  def filters
    @filters ||= TraineeFilter.new(params: filter_params).filters
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
      :sort_by,
      :start_year,
      {
        level: [],
        training_route: [],
        state: [],
        record_source: [],
        record_completion: [],
        cohort: [],
      },
    ]
  end

  def available_record_sources
    sources = {
      "manual" => records_contain_manual_source?,
      "apply" => records_contain_apply_source?,
      "dttp" => records_contain_dttp_source?,
      "hesa" => records_contain_hesa_source?,
    }.select { |_key, value| value == true }.keys

    sources.delete("dttp") unless current_user.system_admin?
    sources
  end

  def show_source_filters?
    available_record_sources.count > 1
  end

  def records_contain_manual_source?
    policy_scope(trainee_search_scope).with_manual_application.count.positive?
  end

  def records_contain_dttp_source?
    policy_scope(trainee_search_scope).created_from_dttp.count.positive?
  end

  def records_contain_apply_source?
    policy_scope(trainee_search_scope).with_apply_application.count.positive?
  end

  def records_contain_hesa_source?
    policy_scope(trainee_search_scope).imported_from_hesa.count.positive?
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
        paginated_trainees: paginated_trainees,
        search_primary_result_title: search_primary_result_title,
        search_primary_result_set: search_primary_result_set,
        search_secondary_result_title: search_secondary_result_title,
        search_secondary_result_set: search_secondary_result_set,
        search_path: search_path,
        filters: filters,
      }),
      selected_filters: render_partial("trainees/selected_filters", {
        filters: filters,
        search_path: search_path,
      }),
      action_bar: render_partial("trainees/action_bar", {
        paginated_trainees: paginated_trainees,
        export_results_path: export_results_path,
      }),
      trainee_count: total_trainees_count,
      page_title: trainees_page_title(paginated_trainees, total_trainees_count),
    }
  end

  def render_partial(partial, locals)
    (render_to_string(formats: %w[html], partial: partial, locals: locals) || "").squish
  end
end

# frozen_string_literal: true

class TraineesController < ApplicationController
  include Breadcrumbable

  before_action :ensure_trainee_is_not_draft!, only: :show

  def index
    @filters = TraineeFilter.new(params: filter_params).filters

    @draft_trainees = Trainees::Filter.call(
      trainees: policy_scope(Trainee.draft.ordered_by_date),
      filters: @filters,
    )
    @trainees = Trainees::Filter.call(
      trainees: policy_scope(Trainee.not_draft.ordered_by_date),
      filters: @filters,
    )
  end

  def show
    authorize trainee
    save_origin_page_for(trainee)
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
    redirect_to OriginPage.new(trainee, session, request).path
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def trainee_params
    params.require(:trainee).permit(:record_type, :trainee_id)
  end

  def filter_params
    params.permit(:subject, :text_search, record_type: [], state: [])
  end
end

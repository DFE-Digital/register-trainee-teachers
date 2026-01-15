# frozen_string_literal: true

module SystemAdmin
  class PendingAwardsController < ApplicationController
    add_flash_types :trs_error
    helper_method :sort_by_items
    before_action :redirect_to_default_sort, only: :index

    def index
      @trainees = sort_trainees
    end

  private

    def sort_trainees
      sort_by = params.fetch(:sort_by, "days_waiting").to_sym

      trainees = Trainee.recommended_for_award.undiscarded

      case sort_by
      when :days_waiting
        trainees.order(recommended_for_award_at: :asc)
      when :trn
        trainees.order(:trn)
      when :register
        trainees.order(:id)
      else
        trainees
      end
    end

    def sort_by_items
      ["Days waiting", "TRN", "Register"]
    end

    def default_sort_by
      "days_waiting"
    end

    def redirect_to_default_sort
      return if params[:sort_by].present?

      redirect_to(action: :index, sort_by: default_sort_by, status: :temporary_redirect)
    end
  end
end

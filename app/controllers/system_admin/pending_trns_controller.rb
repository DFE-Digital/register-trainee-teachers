# frozen_string_literal: true

module SystemAdmin
  class PendingTrnsController < ApplicationController
    helper_method :sort_by_items, :sorted_trainees
    add_flash_types :trs_error
    before_action :redirect_to_default_sort, only: :index

    def index
      @trainees = sorted_trainees
    end

  private

    def sorted_trainees
      sort_by = params.fetch(:sort_by, default_sort_by).to_sym

      trainees = Trainee.includes(:trs_trn_request).submitted_for_trn.undiscarded

      case sort_by
      when :days_waiting
        trainees.sort_by { |t| t.trs_trn_request&.days_waiting || 0 }.reverse
      when :register
        trainees.sort_by(&:id)
      else
        trainees
      end
    end

    def sort_by_items
      ["Days waiting", "Register"]
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

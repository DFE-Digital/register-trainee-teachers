# frozen_string_literal: true

module SystemAdmin
  class DeadJobsController < ApplicationController
    helper_method :dead_job_service, :dead_job_services, :rows, :sort_by_items
    before_action :redirect_to_default_sort, only: :show

    def index; end

    def show
      respond_to do |format|
        format.html
        format.csv do
          send_data(dead_job_service.to_csv, filename: "#{dead_job_service.name}_#{DateTime.now.strftime('%F')}.csv", disposition: :attachment)
        end
      end
    end

    def update
      job&.retry
      flash[:success] = "Job will be retried imminently" # rubocop:disable Rails/I18nLocaleTexts
      redirect_back_or_to(dead_jobs_path)
    end

    def destroy
      job&.delete
      flash[:success] = "Job successfully deleted" # rubocop:disable Rails/I18nLocaleTexts
      redirect_back_or_to(dead_jobs_path)
    end

  private

    def redirect_to_default_sort
      if params[:sort_by].blank? && request.format.html?
        redirect_to(action: :show, id: params[:id], sort_by: default_sort_by, status: :temporary_redirect)
      end
    end

    def default_sort_by
      "days_waiting"
    end

    def sort_by_items
      ["Days waiting", "TRN", "Register"]
    end

    def job
      Sidekiq::DeadSet.new.find_job(params[:id])
    end

    def dead_job_service
      @dead_job_service ||= params[:id]&.constantize&.new
    end

    def sorted_rows
      @sorted_rows ||= dead_job_service.rows.sort_by { |row| row[sort_by] }.reverse
    end

    def sort_by
      @sort_by ||= params.fetch(:sort_by, default_sort_by).to_sym
    end

    def rows
      @rows ||= Kaminari.paginate_array(sorted_rows).page(params[:page] || 1)
    end

    def dead_job_services
      # returns Array of DeadJob classes instances, e.g. [::DeadJobs::TrsUpdateTrainee, ...]
      @dead_job_services ||=
        DeadJobs
          .constants
          .select { |constant| DeadJobs.const_get(constant).is_a?(Class) && constant != :Base }
          .map { |constant| "::DeadJobs::#{constant}".constantize.new }
    end
  end
end

# frozen_string_literal: true

module SystemAdmin
  class DeadJobsController < ApplicationController
    helper_method :dead_job_service, :dead_job_services, :trainees

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

    def job
      Sidekiq::DeadSet.new.find_job(params[:id])
    end

    def dead_job_service
      @dead_job_service ||= params[:id]&.constantize&.new(include_dqt_status:)
    end

    def trainees
      @trainees = Kaminari.paginate_array(dead_job_service.trainees).page(params[:page] || 1)
    end

    def include_dqt_status
      params[:include_dqt_status].present?
    end

    def dead_job_services
      # returns Array of DeadJob classes instances, e.g. [::DeadJobs::DqtUpdateTrainee, ...]
      @dead_job_services ||=
        DeadJobs
          .constants
          .select { |constant| (DeadJobs.const_get(constant).is_a?(Class) && constant != :Base) }
          .map { |constant| "::DeadJobs::#{constant}".constantize.new }
    end
  end
end

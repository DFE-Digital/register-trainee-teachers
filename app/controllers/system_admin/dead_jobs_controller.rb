# frozen_string_literal: true

module SystemAdmin
  class DeadJobsController < ApplicationController
    helper_method :dead_job_service, :dead_job_services

    def show
      respond_to do |format|
        format.html
        format.csv do
          send_data(dead_job_service.to_csv, filename: "#{dead_job_service.name}_#{DateTime.now.strftime('%F')}.csv", disposition: :attachment)
        end
      end
    end

  private

    def dead_job_service
      @dead_job_service ||= params[:id]&.constantize&.new(include_dqt_status:)
    end

    def include_dqt_status
      params[:include_dqt_status].present?
    end

    def dead_job_services
      @dead_job_services ||=
        DeadJobs
          .constants
          # returns Array of DeadJob classes instances, e.g. [::DeadJobs::DqtUpdateTrainee, ...]
          .select { |constant| (DeadJobs.const_get(constant).is_a?(Class) && constant != :Base) }
          .map { |constant| "::DeadJobs::#{constant}".constantize.new }
    end
  end
end

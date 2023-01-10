# frozen_string_literal: true

module SystemAdmin
  class DeadJobsController < ApplicationController
    helper_method :dead_job_service, :dead_job_services

    def show
      respond_to do |format|
        format.html
        format.csv do
          send_data(dead_job_service.csv, filename: "#{dead_job_service.identifier}.csv", disposition: :attachment)
        end
      end
    end

  private

    def dead_job_service
      @dead_job_service ||= params[:id]&.constantize&.new
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

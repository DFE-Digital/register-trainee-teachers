# frozen_string_literal: true

module SystemAdmin
  class DeadJobsController < ApplicationController
    before_action :dead_job_services, only: :index
    helper_method :dead_job_service, :dead_job_services

    def index; end

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
          .select { (DeadJobs.const_get(_1).is_a?(Class) && _1 != :Base) }
          .map { "::DeadJobs::#{_1}".constantize.new }
    end
  end
end

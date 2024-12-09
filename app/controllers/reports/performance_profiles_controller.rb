# frozen_string_literal: true

module Reports
  class PerformanceProfilesController < ApplicationController
    def index
      authorize(current_user, :reports?)

      @previous_academic_cycle = AcademicCycle.previous
      @previous_academic_cycle_label = @previous_academic_cycle.label

      respond_to do |format|
        format.html do
          @trainee_count = performance_profiles_trainees.count
        end

        format.csv do
          authorize(:trainee, :export?)
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers["Content-Type"] = "text/csv; charset=utf-8"
          headers["Content-Disposition"] =
            %(attachment; filename="#{performance_profiles_filename}")
          headers["Last-Modified"] = Time.zone.now.ctime.to_s

          response.status = 200

          self.response_body = Exports::ReportCsvEnumeratorService.call(performance_profiles_trainees)
        end
      end
    end

    private

    def time_now
      Time.now.in_time_zone("London").strftime("%F_%H-%M-%S")
    end

    def performance_profiles_filename
      "#{time_now}_#{@previous_academic_cycle.label('-')}_trainees_performance-profiles-sign-off_register-trainee-teachers.csv"
    end

    def performance_profiles_trainees
      Trainees::Filter.call(trainees: base_trainee_scope, filters: { academic_year: [@previous_academic_cycle.start_year] })
    end

    def base_trainee_scope
      policy_scope(Trainee.includes({ provider: [:courses] }, :start_academic_cycle, :end_academic_cycle).not_draft)
    end
  end
end

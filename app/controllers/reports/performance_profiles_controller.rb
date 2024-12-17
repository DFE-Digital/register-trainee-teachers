# frozen_string_literal: true

module Reports
  class PerformanceProfilesController < ApplicationController
    def index
      authorize(current_user, :reports?)

      redirect_to(reports_path) unless applicable_to_user?

      @previous_academic_cycle = AcademicCycle.previous
      @previous_academic_cycle_label = @previous_academic_cycle.label
      @in_performance_period = DetermineSignOffPeriod.call == :performance_period

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

    def new
      authorize(current_user, :reports?)

      redirect_to(reports_path) unless applicable_to_user? && DetermineSignOffPeriod.call == :performance_period

      @performance_profile_sign_off_form = PerformanceProfileSignOffForm.new
    end

    def create
      authorize(current_user, :reports?)

      redirect_to(reports_path) unless applicable_to_user? && DetermineSignOffPeriod.call == :performance_period

      @performance_profile_sign_off_form = PerformanceProfileSignOffForm.new(sign_off: sign_off, provider: current_user.organisation, user: current_user)

      if @performance_profile_sign_off_form.save!
        redirect_to(confirmation_reports_performance_profiles_path)
      else
        render(:new)
      end
    end

    def confirmation
      authorize(current_user, :reports?)

      redirect_to(reports_path) unless current_user.provider? && current_user.organisation.performance_profile_signed_off? && DetermineSignOffPeriod.call == :performance_period
    end

  private

    def applicable_to_user?
      current_user.provider? && current_user.organisation.performance_profile_awaiting_sign_off? && DetermineSignOffPeriod.call == :performance_period
    end

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

    def sign_off
      params.require(:performance_profile_sign_off_form).permit(:sign_off)[:sign_off]
    end
  end
end

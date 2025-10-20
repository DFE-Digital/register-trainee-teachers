# frozen_string_literal: true

module Reports
  class CensusesController < ApplicationController
    before_action :redirect_if_not_applicable, only: %i[index create new]

    helper_method :itt_new_starter_trainees

    def index
      authorize(current_user, :reports?)

      @current_academic_cycle = AcademicCycle.current
      @current_academic_cycle_label = @current_academic_cycle.label

      respond_to do |format|
        format.html do
          @sign_off_url = Settings.sign_off_trainee_data_url
          @census_date = @current_academic_cycle.second_wednesday_of_october
        end

        format.csv do
          authorize(:trainee, :export?)
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers["Content-Type"] = "text/csv; charset=utf-8"
          headers["Content-Disposition"] =
            %(attachment; filename="#{itt_new_starter_filename}")
          headers["Last-Modified"] = Time.zone.now.ctime.to_s

          response.status = 200

          self.response_body = Exports::ReportCsvEnumeratorService.call(itt_new_starter_trainees)
        end
      end

      authorize(current_user, :reports?)
    end

    def new
      authorize(current_user, :reports?)

      @current_academic_cycle = AcademicCycle.current
      @current_academic_cycle_label = @current_academic_cycle.label

      @census_sign_off_form = CensusSignOffForm.new
    end

    def create
      authorize(current_user, :reports?)

      @census_sign_off_form = CensusSignOffForm.new(sign_off: sign_off, provider: current_user.organisation, user: current_user)

      if @census_sign_off_form.save!
        email_provider_users
        redirect_to(confirmation_reports_censuses_path)
      else
        @current_academic_cycle = AcademicCycle.current
        @current_academic_cycle_label = @current_academic_cycle.label
        render(:new)
      end
    end

    def confirmation
      authorize(current_user, :reports?)

      redirect_to(reports_path) unless current_user.provider? && current_user.organisation.census_signed_off? && DetermineSignOffPeriod.call == :census_period
    end

  private

    def redirect_if_not_applicable
      redirect_to(reports_path) unless applicable_to_user?
    end

    def applicable_to_user?
      current_user.provider? && current_user.organisation.census_awaiting_sign_off? && DetermineSignOffPeriod.call == :census_period
    end

    def time_now
      Time.now.in_time_zone("London").strftime("%F_%H-%M-%S")
    end

    def censuses_filename
      "#{time_now}_#{@current_academic_cycle.label('-')}_trainees_censuses-sign-off_register-trainee-teachers.csv"
    end

    def censuses_trainees
      Trainees::Filter.call(
        trainees: base_trainee_scope,
        filters: {
          academic_year: [@current_academic_cycle.start_year],
          not_withdrawn_before: @current_academic_cycle.second_wednesday_of_october,
        },
      )
    end

    def base_trainee_scope
      policy_scope(Trainee.includes({ provider: [:courses] }, :start_academic_cycle, :end_academic_cycle).not_draft)
    end

    def email_provider_users
      SendCensusSubmittedEmailService.call(provider: current_user.organisation, submitted_at: Time.zone.now)
    end

    def itt_new_starter_trainees
      @itt_new_starter_trainees ||= policy_scope(FindNewStarterTrainees.new(@current_academic_cycle.second_wednesday_of_october).call)
    end

    def itt_new_starter_filename
      "#{time_now}_New-trainees-#{@current_academic_cycle.label('-')}-sign-off-Register-trainee-teachers_exported_records.csv"
    end

    def sign_off
      params.require(:census_sign_off_form).permit(:sign_off)[:sign_off]
    end
  end
end

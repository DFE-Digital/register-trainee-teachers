# frozen_string_literal: true

module Reports
  class HeQualificationsController < ApplicationController
    before_action :redirect_if_not_applicable, only: %i[index]

    def index
      authorize(current_user, :reports?)

      @previous_academic_cycle = AcademicCycle.previous
      @previous_academic_cycle_label = @previous_academic_cycle.label

      respond_to do |format|
        format.csv do
          authorize(:trainee, :export?)
          headers["X-Accel-Buffering"] = "no"
          headers["Cache-Control"] = "no-cache"
          headers["Content-Type"] = "text/csv; charset=utf-8"
          headers["Content-Disposition"] =
            %(attachment; filename="#{performance_profiles_filename}")
          headers["Last-Modified"] = Time.zone.now.ctime.to_s

          response.status = 200

          self.response_body = Exports::ReportCsvEnumeratorService.call(he_qualifications)
        end
      end
    end

  private

    def he_qualifications
      # TODO: filter by date or academic cycle?

      Degree.include(:trainee).order(:trainee_id)
    end
  end
end

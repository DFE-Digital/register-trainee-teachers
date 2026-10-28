# frozen_string_literal: true

module Reports
  class PlacementsController < ApplicationController
    def index
      authorize(current_user, :reports?)
      authorize(:trainee, :export?)

      headers["X-Accel-Buffering"] = "no"
      headers["Cache-Control"] = "no-cache"
      headers["Content-Type"] = "text/csv; charset=utf-8"
      headers["Content-Disposition"] = %(attachment; filename="#{placements_filename}")
      headers["Last-Modified"] = Time.zone.now.ctime.to_s

      response.status = 200
      render(plain: Exports::PlacementsExport.call(placements_trainees))
    end

  private

    def placements_trainees
      current_user.organisation.trainees_for_placements_report
    end

    def placements_filename
      "#{AcademicCycle.current.label('-')}-placements-report-#{time_now}.csv"
    end

    def time_now
      Time.now.in_time_zone("London").strftime("%F_%H-%M-%S")
    end
  end
end

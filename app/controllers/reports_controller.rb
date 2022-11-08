# frozen_string_literal: true

class ReportsController < BaseTraineeController
  include DateOfTheNthWeekdayHelper
  include UsersHelper
  include TraineeHelper

  def index
    authorize(current_user, :reports?)
  end

  def itt_new_starter_data_sign_off
    authorize(current_user, :reports?)
    set_instance_variables
    respond_to do |format|
      format.html do
        @census_date = census_date(@current_academic_cycle_start_year).strftime("%d %B %Y")
      end
      format.csv do
        authorize(:trainee, :export?)
        send_data(data_for_export.data, filename: filename, disposition: :attachment)
      end
    end
  end

private

  def set_instance_variables
    @current_academic_cycle_label = AcademicCycle.current.label
    @current_academic_cycle_start_year = AcademicCycle.current.start_year
    @sign_off_url = Settings.sign_off_trainee_data_url
  end

  def data_for_export
    @data_for_export ||= Exports::ExportTraineesService.call(
      policy_scope(FindNewStarterTrainees.new(census_date(AcademicCycle.current.start_year)).call),
    )
  end

  def filename
    current_time = Time.zone.now
    "#{current_time.strftime('%F_%H_%M_%S')}_New-trainees-#{AcademicCycle.current.start_year}-#{AcademicCycle.current.end_year}-sign-off-Register-trainee-teachers_exported_records.csv"
  end

  def census_date(year)
    date_of_nth_weekday(10, year, 3, 2)
  end
end

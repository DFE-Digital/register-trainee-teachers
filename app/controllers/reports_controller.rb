# frozen_string_literal: true

class ReportsController < BaseTraineeController
  include DateOfTheNthWeekdayHelper

  before_action :set_year_labels

  def index
    authorize(current_user, :reports?)
  end

  def itt_new_starter_data_sign_off
    authorize(current_user, :reports?)

    respond_to do |format|
      format.html do
        @current_academic_cycle_start_year = AcademicCycle.current.start_year
        @sign_off_url = Settings.sign_off_trainee_data_url
        @census_date = census_date(@current_academic_cycle_start_year).strftime("%d %B %Y")
      end
      format.csv do
        authorize(:trainee, :export?)
        send_data(
          Exports::ExportTraineesService.call(itt_new_starter_trainees),
          filename: itt_new_starter_filename,
          disposition: :attachment,
        )
      end
    end
  end

  def performance_profiles
    authorize(current_user, :reports?)

    respond_to do |format|
      format.html do
        @sign_off_date = Date.new(AcademicCycle.current.end_year, 1, 31).strftime("%d %B %Y")
      end
      format.csv do
        authorize(:trainee, :export?)
        send_data(
          Exports::ExportTraineesService.call(performance_profiles_trainees),
          filename: performance_profiles_filename,
          disposition: :attachment,
        )
      end
    end
  end

private

  def itt_new_starter_trainees
    policy_scope(FindNewStarterTrainees.new(census_date(AcademicCycle.current.start_year)).call)
  end

  def performance_profiles_trainees
    policy_scope(FindNewStarterTrainees.new(census_date(AcademicCycle.current.start_year)).call)
  end

  def itt_new_starter_filename
    "#{Time.zone.now.strftime('%F_%H_%M_%S')}_New-trainees-#{AcademicCycle.current.label.parameterize}-#{AcademicCycle.current.end_year}-sign-off-Register-trainee-teachers_exported_records.csv"
  end

  def performance_profiles_filename
    "#{Time.zone.now.strftime('%F_%H_%M_%S')}_Performance-profiles-sign-off-Register-trainee-teachers_exported_records.csv"
  end

  def census_date(year)
    date_of_nth_weekday(10, year, 3, 2)
  end

  def set_year_labels
    @current_academic_cycle_label = AcademicCycle.current.label
    @previous_academic_cycle_label = AcademicCycle.previous.label
  end
end

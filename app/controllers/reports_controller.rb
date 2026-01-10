# frozen_string_literal: true

class ReportsController < BaseTraineeController
  include DateOfTheNthWeekdayHelper

  before_action :set_cycle_variables

  helper_method :itt_new_starter_trainees

  def index
    authorize(current_user, :reports?)

    @partial_page = DetermineSignOffPeriod.call

    if @partial_page == :performance_period
      if current_user.organisation.nil? && current_user.system_admin?
        @partial_page = :system_admin_with_no_associated_provider
      elsif current_user.organisation.performance_profile_signed_off?
        @partial_page = :outside_period
      end
    end

    if @partial_page == :census_period
      if current_user.organisation.nil? && current_user.system_admin?
        @partial_page = :system_admin_with_no_associated_provider
      elsif current_user.organisation.census_signed_off?
        @partial_page = :outside_period
      end
    end
  end

  def bulk_recommend_export
    authorize(current_user, :bulk_recommend?)

    send_data(
      Exports::BulkRecommendExport.call(bulk_recommend_trainees),
      filename: bulk_recommend_export_filename,
      disposition: :attachment,
    )
  end

  def bulk_recommend_empty_export
    authorize(current_user, :bulk_recommend?)

    send_data(
      Exports::BulkRecommendEmptyExport.call,
      filename: bulk_recommend_empty_export_filename,
      disposition: :attachment,
    )
  end

private

  def bulk_recommend_trainees
    policy_scope(FindBulkRecommendTrainees.call).order(last_name: :asc)
  end

  def time_now
    Time.now.in_time_zone("London").strftime("%F_%H-%M-%S")
  end

  def bulk_recommend_export_filename
    "#{current_user.organisation.name.parameterize}-trainees-to-change-status-prepopulated.csv"
  end

  def bulk_recommend_empty_export_filename
    "#{current_user.organisation.name.parameterize}-trainees-to-change-status-empty.csv"
  end

  def census_date(year)
    date_of_nth_weekday(10, year, 3, 2)
  end

  def set_cycle_variables
    @current_academic_cycle = AcademicCycle.current
    @previous_academic_cycle = AcademicCycle.previous
    @current_academic_cycle_label = @current_academic_cycle.label
    @previous_academic_cycle_label = @previous_academic_cycle.label
  end

  def base_trainee_scope
    policy_scope(Trainee.includes({ provider: [:courses] }, :start_academic_cycle, :end_academic_cycle).not_draft)
  end
end

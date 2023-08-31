# frozen_string_literal: true

class GuidanceController < ApplicationController
  skip_before_action :authenticate
  helper_method :signing_off_period

  def show
    render(layout: "application")
  end

  def about_register_trainee_teachers; end
  def registering_trainees_through_hesa; end
  def check_data; end
  def bulk_recommend_trainees; end
  def manually_registering_trainees; end
  def census_sign_off; end

  def dates_and_deadlines
    render(layout: "application")
  end

  def hesa_register_data_mapping
    tab_param = params[:tab].underscore
    @tab = valid_tabs.include?(tab_param) ? tab_param : "trainee_progress"
    render(layout: "application")
  end

  def performance_profiles
    case sign_off_period
    when :performance_period
      @current_academic_cycle_label = current_academic_cycle.label
      @previous_academic_cycle_label = previous_academic_cycle.label
      @academic_cycle_for_filter = previous_academic_cycle.start_year
      @sign_off_deadline = Date.new(AcademicCycle.current.end_year, 1, 31).strftime("%d %B %Y")
      @sign_off_url = Settings.sign_off_performance_profiles_url
      render(layout: "application")
    when :census_period, :outside_period
      render(:performance_profiles_outside, layout: "application")
    end
  end

private

  def previous_academic_cycle
    @previous_academic_cycle ||= AcademicCycle.previous
  end

  def current_academic_cycle
    @current_academic_cycle ||= AcademicCycle.current
  end

  def valid_tabs
    %w[course_details database_only funding schools trainee_progress personal_details]
  end

  def sign_off_period
    @sign_off_period ||= DetermineSignOffPeriod.call
  end
end

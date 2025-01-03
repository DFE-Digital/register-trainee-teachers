# frozen_string_literal: true

class GuidanceController < ApplicationController
  skip_before_action :authenticate
  helper_method :sign_off_period, :previous_academic_cycle

  def show
    render(layout: "application")
  end

  def about_register_trainee_teachers; end
  def registering_trainees_through_hesa; end
  def check_data; end
  def bulk_recommend_trainees; end
  def manually_registering_trainees; end

  def manage_placements
    render(layout: "application")
  end

  def bulk_upload_placement_data
    previous_academic_cycle
    render(layout: "application")
  end

  def census_sign_off
    render(layout: "application")
  end

  def dates_and_deadlines
    @performance_profile_sign_off_full_deadline = performance_profile_sign_off_date.strftime("%d %B %Y")
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
      @sign_off_deadline = performance_profile_sign_off_date.strftime("%d %B %Y")
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

  def performance_profile_sign_off_date
    @performance_profile_sign_off_date ||= previous_academic_cycle.performance_profile_date_range.end
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

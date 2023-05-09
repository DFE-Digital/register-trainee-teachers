# frozen_string_literal: true

class GuidanceController < ApplicationController
  skip_before_action :authenticate
  helper_method :signing_off_data

  def show
    render(layout: "application")
  end

  def about_register_trainee_teachers; end
  def registering_trainees_through_hesa; end
  def check_data; end
  def bulk_recommend_trainees; end
  def manually_registering_trainees; end

  def dates_and_deadlines
    render(layout: "application")
  end

  def hesa_register_data_mapping
    tab_param = params[:tab].underscore
    @tab = valid_tabs.include?(tab_param) ? tab_param : "trainee_progress"
    render(layout: "application")
  end

  def performance_profiles
    if Settings.in_sign_off_period?
      @current_academic_cycle_label = current_academic_cycle.label
      @previous_academic_cycle_label = previous_academic_cycle.label
      @academic_cycle_for_filter = previous_academic_cycle.start_year
      @sign_off_deadline = Date.new(AcademicCycle.current.end_year, 1, 31).strftime("%d %B %Y")
      @sign_off_url = Settings.sign_off_performance_profiles_url
      render(layout: "application")
    else
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

  def signing_off_data
    @signing_off_data ||= if Settings.in_sign_off_period?
                            "Sign off your list of trainees from #{previous_academic_cycle.label} for the performance profiles publication"
                          else
                            "Signing off your list of trainees for the performance profiles publication"
                          end
  end

  def valid_tabs
    %w[course_details database_only funding schools trainee_progress personal_details]
  end
end

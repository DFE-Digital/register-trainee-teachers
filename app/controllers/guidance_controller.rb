# frozen_string_literal: true

class GuidanceController < ApplicationController
  skip_before_action :authenticate

  def show
    render(layout: "application")
  end

  def about_register_trainee_teachers; end

  def dates_and_deadlines
    render(layout: "application")
  end

  def manually_registering_trainees; end

  def registering_trainees_through_hesa; end

  def check_data; end

  def hesa_register_data_mapping
    tab_param = params[:tab].underscore
    @tab = valid_tabs.include?(tab_param) ? tab_param : "trainee_progress"
    render(layout: "application")
  end

private

  def valid_tabs
    %w[course_details database_only funding schools trainee_progress personal_details]
  end
end

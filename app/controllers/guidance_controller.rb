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
end

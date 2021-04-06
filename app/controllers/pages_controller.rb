# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate

  def start
    session[:requested_path] = root_path
    if authenticated?
      @trainees = policy_scope(Trainee.all)
      render :home
    else
      render :start
    end
  end

  def accessibility
    render :accessibility
  end

  def cookie_policy
    render :cookie_policy
  end

  def privacy_policy
    render :privacy_policy
  end

  def data_requirements
    render :data_requirements
  end
end

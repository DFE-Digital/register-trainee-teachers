# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    skip_authorization
    session[:auth_user] = { user_id: params[:user_id] }
    redirect_to trainees_path
  end
end

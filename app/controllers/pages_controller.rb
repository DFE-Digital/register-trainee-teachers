# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    render template: "pages/#{params[:page]}"
  end

  def accessibility
    render :accessibility
  end

  def cookies
    render :cookies
  end

  def privacy_policy
    render :privacy_policy
  end
end

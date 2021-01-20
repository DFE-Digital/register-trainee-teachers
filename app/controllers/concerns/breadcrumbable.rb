# frozen_string_literal: true

module Breadcrumbable
  def save_origin_page_for(trainee)
    # Don't save it the same origin page on page refresh, for example.
    unless current_page == origin_pages_for(trainee).last
      origin_pages_for(trainee) << current_page
    end

    # We only need to keep track of the last two origin pages.
    origin_pages_for(trainee).shift if origin_pages_for(trainee).length > 2
  end

  def origin_pages_for(trainee)
    session[session_key_for(trainee)] ||= []
  end

  def current_page
    routes = Rails.application.routes.router.recognize(request) do |route, _|
      route.name
    end

    routes.flatten.last.name
  end

private

  def session_key_for(trainee)
    "origin_pages_for_#{trainee.id}"
  end
end

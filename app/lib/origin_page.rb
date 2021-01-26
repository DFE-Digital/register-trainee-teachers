# frozen_string_literal: true

class OriginPage
  include TraineeHelper
  include Rails.application.routes.url_helpers

  MAX_PAGES = 2 # We only need to keep track of the last two origin pages.

  def initialize(trainee, session, request)
    @trainee = trainee
    @session = session
    @request = request
    @origin_pages = origin_pages_for(trainee)
  end

  def save
    # Don't save it the same origin page on page refresh, for example.
    origin_pages << current_page unless origin_pages.include?(current_page)

    origin_pages.shift if origin_pages.length > MAX_PAGES
  end

  def path
    return view_trainee(trainee) unless origin_pages.any?

    if on_origin_page?
      # Return the origin page before this one if it's been stored
      return origin_pages.length < MAX_PAGES ? view_trainee(trainee) : rails_path(origin_pages[-2])
    end

    rails_path(origin_pages.last)
  end

private

  attr_reader :trainee, :session, :request, :origin_pages, :on_confirm_page

  def origin_pages_for(trainee)
    session["origin_pages_for_#{trainee.id}"] ||= []
  end

  def current_page
    request_route.name
  end

  def rails_path(route)
    public_send("#{route}_path", trainee)
  end

  def on_origin_page?
    current_page == origin_pages.last || on_confirm_page?
  end

  def on_confirm_page?
    request_route.ast.to_s.include?("confirm")
  end

  def request_route
    Rails.application.routes.router.recognize(request) { |route, _| route.name }.first.last
  end
end

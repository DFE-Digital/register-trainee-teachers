# frozen_string_literal: true

module DynamicBackLink
  class View < GovukComponent::Base
    include TraineeHelper
    include Breadcrumbable

    def initialize(trainee)
      @trainee = trainee
    end

    def text
      trainee.draft? ? "Back to draft record" : "Back to record"
    end

    def path
      return view_trainee(trainee) unless origin_pages.any?

      # If you're currently on a 'confirm' page, then you're on an origin page
      # that has a back button to the _previous_ origin page.
      if on_origin_page?
        # Therefore, return the origin page before this one if it's been stored.
        return origin_pages.length < 2 ? view_trainee(trainee) : rails_path(origin_pages[-2])
      end

      rails_path(origin_pages.last)
    end

  private

    attr_reader :trainee

    def rails_path(route)
      public_send("#{route}_path", trainee)
    end

    def origin_pages
      @origin_pages ||= origin_pages_for(trainee)
    end

    def on_origin_page?
      current_page == origin_pages.last
    end
  end
end

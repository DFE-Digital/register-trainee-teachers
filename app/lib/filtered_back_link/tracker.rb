# frozen_string_literal: true

module FilteredBackLink
  class Tracker
    attr_reader :session, :href

    def initialize(session:, href:)
      @session = session
      @href = href
    end

    def scope
      @scope ||= "filtered_back_link_#{href.parameterize}"
    end

    def save_path(url)
      session[scope] = url
    end

    def get_path
      session[scope] || href
    end
  end
end

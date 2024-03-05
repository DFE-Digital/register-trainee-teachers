# frozen_string_literal: true

module NavigationHelper
  def active_link_for(segment, trainee = nil)
    url = request.path_info

    {
      drafts: -> { trainee&.draft? && segment == "drafts" },
      trainees: -> { url.include?("/#{segment}") && !trainee&.draft? },
      bulk: -> { url.include?(segment) },
      reports: -> { url.include?("reports") },
      funding: -> { url.include?("funding") },
    }[segment.to_sym].call
  end
end

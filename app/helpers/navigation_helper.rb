# frozen_string_literal: true

module NavigationHelper
  def active_link_for(segment, trainee = nil)
    url = request.path_info

    {
      drafts: -> { trainee&.draft? && segment == "drafts" },
      trainees: -> { url.include?("/#{segment}") && !trainee&.draft? },
      recommend: -> { url.include?(segment) },
      reports: -> { url.include?("reports") },
      funding: -> { ["/funding/monthly-payments", "/funding/trainee-summary"].include?(url) },
    }[segment.to_sym].call
  end
end

# frozen_string_literal: true

module NavigationHelper
  def active_link_for(segment)
    url = request.path_info
    url.include?("/#{segment}")
  end
end

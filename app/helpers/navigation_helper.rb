# frozen_string_literal: true

module NavigationHelper
  def trainee_link_is_current?
    url = request.path_info
    url.include?("/trainees")
  end
end

# frozen_string_literal: true

module NavigationHelper
  def trainee_link_is_current?
    url = request.path_info
    if url.include?("/trainees")
      true
    else
      false
    end
  end
end

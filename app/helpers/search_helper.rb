# frozen_string_literal: true

module SearchHelper
  def trainee_search_path?(search_path)
    search_path == "/trainees"
  end
end

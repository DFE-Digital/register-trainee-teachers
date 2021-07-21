# frozen_string_literal: true

module InvalidDataSummary
  class ViewPreview < ViewComponent::Preview
    def default
      data = { "degrees" => [{ "institution" => "University of Warwick" }] }
      render(View.new(data: data))
    end
  end
end

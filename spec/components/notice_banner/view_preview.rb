# frozen_string_literal: true

module NoticeBanner
  class ViewPreview < ViewComponent::Preview
    def default
      render NoticeBanner::View.new do |component|
        component.with_header { "Header" }
        "Content"
      end
    end
  end
end

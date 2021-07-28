# frozen_string_literal: true

module InformationSummary
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(renderable: true)) do
        missing_data_item_content
      end
    end

    def with_header_content
      render(View.new(renderable: true)) do |component|
        component.header do
          "Some header content"
        end

        missing_data_item_content
      end
    end

  private

    def missing_data_item_content
      "<li><a class='govuk-notification-banner__link' href='#subject'>Subject is not recognised</a></li>".html_safe
    end
  end
end

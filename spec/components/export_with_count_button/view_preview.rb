# frozen_string_literal: true

module ExportWithCountButton
  class ViewPreview < ViewComponent::Preview
    def default
      render(
        View.new(
          button_text: "Export",
          count: 1,
          count_label: "trainee",
          href: "/export",
        ),
      )
    end

    def with_no_record_text
      render(
        View.new(
          button_text: "Export",
          count: 0,
          count_label: "trainee",
          href: "/export",
        ),
      ) do |component|
        component.no_record_text { "No trainees found." }
      end
    end
  end
end

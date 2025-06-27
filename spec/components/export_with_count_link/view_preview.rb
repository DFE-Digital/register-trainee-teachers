# frozen_string_literal: true

module ExportWithCountLink
  class ViewPreview < ViewComponent::Preview
    def default
      render(
        View.new(
          link_text: "Export",
          count: 1,
          count_label: "trainee",
          href: "/export",
        ),
      )
    end

    def with_no_record_text
      render(
        View.new(
          link_text: "Export",
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

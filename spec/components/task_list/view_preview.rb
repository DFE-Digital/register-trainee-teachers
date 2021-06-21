# frozen_string_literal: true

class TaskList::ViewPreview < ViewComponent::Preview
  def default_state
    render TaskList::View.new do |component|
      component.row(
        task_name: "Personal details",
        path: "#aardvark",
        status: "completed",
      )
    end
  end

  def with_inactive_row
    render TaskList::View.new do |component|
      component.row(
        task_name: "Funding",
        path: nil,
        status: "cannot start yet",
        hint_text: "Complete course details first",
        active: false,
      )
    end
  end

  def with_multiple_status
    render TaskList::View.new do |component|
      component.row(
        task_name: "Personal details",
        path: "#aardvark",
        status: "completed",
      )

      component.row(
        task_name: "Contact details",
        path: "#details",
        status: "in progress",
      )

      component.row(
        task_name: "Diversity information",
        path: "#diversity",
        status: "not started",
      )

      component.row(
        task_name: "Course details",
        path: "#some_path",
        status: "review",
      )
    end
  end
end

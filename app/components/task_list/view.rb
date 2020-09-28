class TaskList::View < GovukComponent::Base
  include ViewComponent::Slotable

  with_slot :row, collection: true, class_name: "Row"
  wrap_slot :row

  def any_row_has_status?
    rows.any? { |r| r.status.present? }
  end

private

  def default_classes
    %w[app-task-list]
  end

  class Row < GovukComponent::Slot
    attr_accessor :task_name, :path, :status

    def initialize(task_name:, path:, status:, classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)

      @task_name = task_name
      @path = path
      @status = status
    end

    def get_status_colour
      {
        # use default white text on dark blue background
        "completed" => "blue",
        "in progress" => "grey",
        "not started" => "grey",
      }.fetch(status, "grey")
    end

  private

    def default_classes
      %w[app-task-list__item]
    end
  end
end

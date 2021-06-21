# frozen_string_literal: true

class TaskList::View < GovukComponent::Base
  renders_many :rows, "Row"

  def any_row_has_status?
    rows.any? { |r| r.status.present? }
  end

private

  def default_classes
    %w[app-task-list]
  end

  class Row < GovukComponent::Slot
    attr_accessor :task_name, :status, :hint_text, :active

    def initialize(task_name:, path:, confirm_path: nil, status:, hint_text: nil, active: true, classes: [], html_attributes: {})
      super(classes: classes, html_attributes: html_attributes)

      @task_name = task_name
      @path = path
      @confirm_path = confirm_path
      @status = status
      @hint_text = hint_text
      @active = active
    end

    def get_path
      return path unless @confirm_path

      status == Progress::STATUSES[:not_started] ? path : confirm_path
    end

    def get_status_colour
      {
        # use default white text on dark blue background
        Progress::STATUSES[:completed] => "blue",
        Progress::STATUSES[:in_progress] => "grey",
        Progress::STATUSES[:review] => "pink",
        Progress::STATUSES[:not_started] => "grey",
      }.fetch(status, "grey")
    end

    def status_id
      "#{task_name.downcase.parameterize}-status"
    end

  private

    def path
      @path.respond_to?(:call) ? @path.call : @path
    end

    def confirm_path
      @confirm_path.respond_to?(:call) ? @confirm_path.call : @confirm_path
    end

    def default_classes
      %w[app-task-list__item]
    end
  end
end

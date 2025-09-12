# frozen_string_literal: true

class TaskList::View < ApplicationComponent
  renders_many :rows, "Row"

  def any_row_has_status?
    rows.any? { |r| r.status.present? }
  end

private

  def default_classes
    %w[app-task-list]
  end

  class Row < GovukComponent::Base
    attr_accessor :task_name, :status, :hint_text, :active, :classes

    def initialize(task_name:, path:, confirm_path: nil, status:, hint_text: nil, active: true, classes: [])
      @classes = [default_classes, classes]

      @task_name = task_name
      @path = path
      @confirm_path = confirm_path
      @status = status
      @hint_text = hint_text
      @active = active
    end

    def get_path
      return path unless @confirm_path

      if Progress::STATUSES.slice(:incomplete, :in_progress_invalid).values.include?(status)
        path
      else
        confirm_path
      end
    end

    def get_status_colour
      {
        # use default white text on dark blue background
        Progress::STATUSES[:completed] => "blue",
        Progress::STATUSES[:in_progress_valid] => "grey",
        Progress::STATUSES[:in_progress_invalid] => "grey",
        Progress::STATUSES[:review] => "pink",
        Progress::STATUSES[:incomplete] => "grey",
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

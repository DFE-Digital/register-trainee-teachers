# frozen_string_literal: true

require "govuk/components"
class MappableSummary::ViewPreview < ViewComponent::Preview
  def non_editable_record
    render(MappableSummary::View.new(trainee: mock_closed_trainee, system_admin: false, title: "Star Wars", rows: missing_data_rows, has_errors: nil))
  end

  def editable_record
    render(MappableSummary::View.new(trainee: mock_open_trainee, system_admin: false, title: "Star Wars", rows: missing_data_rows, has_errors: nil))
  end

  def editable_record_with_change_link
    render(MappableSummary::View.new(trainee: mock_open_trainee, system_admin: false, title: "Star Wars", rows: rows, has_errors: nil))
  end

private

  def mock_closed_trainee
    @mock_closed_trainee ||= Trainee.new(
      first_names: "Luke",
      last_name: "Skywalker",
      state: "withdrawn",
    )
  end

  def mock_open_trainee
    @mock_open_trainee ||= Trainee.new(
      first_names: "Luke",
      last_name: "Skywalker",
      state: "submitted_for_trn",
    )
  end

  def missing_data_rows
    [
      { field_label: "Jedi", field_value: nil, action_url: "#path" },
    ]
  end

  def rows
    [
      { field_label: "Jedi", field_value: "Returns", action_url: "#path" },
    ]
  end
end

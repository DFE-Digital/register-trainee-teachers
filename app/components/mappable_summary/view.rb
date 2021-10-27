# frozen_string_literal: true

class MappableSummary::View < ViewComponent::Base
  include MappableFieldHelper

  attr_reader :title, :rows, :system_admin, :trainee, :has_errors, :id_suffix

  renders_one :header_actions

  def initialize(trainee:, title:, rows:, system_admin:, has_errors:, id_suffix: nil)
    @trainee = trainee
    @title = title
    @rows = rows
    @system_admin = system_admin
    @has_errors = has_errors
    @id_suffix = id_suffix
  end

  def mappable_rows
    rows.map do |row|
      if row[:custom_value] == true
        custom_row(row)
      elsif row[:degree].present?
        mappable_degree_field_row(row[:degree], row[:field_name], row[:field_label], row[:field_value])
      else
        mappable_field(row[:field_value], row[:field_label], row[:action_url])
      end
    end
  end

  def action_attributes(row)
    return {} if row[:action_href].nil? || non_editable

    row.slice(:action_href, :action_text, :action_visually_hidden_text)
  end

  def custom_row(row)
    row.slice(:key, :value).merge(action_attributes(row))
  end
end

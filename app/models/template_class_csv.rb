# frozen_string_literal: true

class TemplateClassCsv
  def initialize(csv, scope:)
    @csv = csv
    @scope = scope
  end

  def generate_report
    add_headers
    add_report_rows
  end

private

  attr_accessor :csv, :scope

  def add_headers
    raise(NotImplementedError)
  end

  def add_report_rows
    raise(NotImplementedError)
  end
end

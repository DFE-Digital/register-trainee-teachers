# frozen_string_literal: true

class CourseYearsForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_writer :course_year

  validates :course_year, inclusion: { in: ->(rec) { rec.course_years_options.keys } }

  def initialize(params = {})
    assign_attributes(params)
  end

  def course_year
    @course_year.to_i
  end

  def course_years_options
    [
      default_course_year + 1,
      default_course_year,
      default_course_year - 1,
    ].inject({}) do |sum, y|
      sum[y] = "#{y} to #{y + 1}#{' (current year)' if y == default_course_year}"
      sum
    end
  end

  def default_course_year
    Settings.current_default_course_year
  end
end

# frozen_string_literal: true

class CourseYearsForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  attr_writer :course_year

  validates :course_year, inclusion: { in: ->(rec) { rec.course_years_options.keys } }

  def initialize(trainee: nil, params: {})
    assign_attributes(params)
    @trainee = trainee
  end

  def course_year
    @course_year.to_i
  end

  # { 2022=>"2022 to 2023", 2021 => "2021 to 2022" }
  def course_years_options
    course_year_to.downto(course_year_from).map.index_with { |year| "#{year} to #{year + 1}" }
  end

private

  def course_year_from
    [
      recruitment_cycle_year,
      itt_start_date_year,
      course_year_to - 1,
    ].compact.min
  end

  def itt_start_date_year
    return unless trainee&.itt_start_date

    AcademicCycle.for_date(trainee.itt_start_date).start_year
  end

  def recruitment_cycle_year
    return unless trainee&.current_course&.recruitment_cycle_year

    trainee.current_course.recruitment_cycle_year + 1
  end

  def course_year_to
    Settings.current_default_course_year
  end

  attr_reader :trainee
end

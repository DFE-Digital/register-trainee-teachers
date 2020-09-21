module View
  class TraineeCourseDetailsPresenter
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def call
      relevant_attributes.map { |k, v|
        [Trainee.human_attribute_name(k), v]
      }.to_h
    end

  private

    def relevant_attributes
      trainee.attributes.select { |k, _v| relevant_fields.include?(k) }
    end

    def relevant_fields
      %w[
        course_title
        course_phase
        programme_start_date
        programme_length
        programme_end_date
        allocation_subject
        itt_subject
        employing_school
        placement_school
      ]
    end
  end
end

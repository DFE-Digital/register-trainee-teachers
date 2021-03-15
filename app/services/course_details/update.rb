# frozen_string_literal: true

module CourseDetails
  class Update
    include ServicePattern

    attr_reader :trainee, :course_detail, :successful

    alias_method :successful?, :successful

    def initialize(trainee:, attributes: {})
      @trainee = trainee

      @course_detail = CourseDetailForm.new(trainee)
      @course_detail.assign_attributes(attributes)
    end

    def call
      @successful = course_detail.valid? && trainee.save!

      self
    end
  end
end

# frozen_string_literal: true

module ApplyApplications
  class ReviewCourseForm
    include ActiveModel::Model
    include ActiveModel::AttributeAssignment

    REGISTER = "register"
    CHANGE = "change"

    REVIEWED_VALUES = [REGISTER, CHANGE].freeze

    FIELDS = %i[
      reviewed
      uuid
    ].freeze

    attr_accessor(*FIELDS)

    validates :reviewed, presence: true

    def registered?
      reviewed == REGISTER
    end
  end
end

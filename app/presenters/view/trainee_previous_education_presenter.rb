module View
  class TraineePreviousEducationPresenter
    attr_reader :trainee

    def initialize(trainee)
      @trainee = trainee
    end

    def call
      relevant_attributes.map { |k, v|
        [I18n.t("presenters.TraineePreviousEducation.attributes.#{k}"), present_boolean(v)]
      }.to_h
    end

  private

    def present_boolean(value)
      case value
      when true
        "Yes"
      when false
        "No"
      else
        value
      end
    end

    def a_levels_and_grades
      {
        first_a_level: "#{trainee.a_level_1_subject} - #{trainee.a_level_1_grade}",
        second_a_level: "#{trainee.a_level_2_subject} - #{trainee.a_level_2_grade}",
        third_a_level: "#{trainee.a_level_3_subject} - #{trainee.a_level_3_grade}",
      }
    end

    def relevant_attributes
      attrs = a_levels_and_grades
      attrs.merge(trainee.attributes.select { |k, _v| relevant_fields.include?(k) })
    end

    def relevant_fields
      %w[
        degree_subject
        degree_class
        ske
        previous_qts
      ]
    end
  end
end

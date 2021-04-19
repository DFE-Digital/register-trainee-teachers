# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCoursesSpike
    include ServicePattern

    class Error < StandardError; end

    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      @data = JSON(response.body)

      select_course_attributes
    end

  private

    attr_reader :data, :course

    def response
      @response ||= Client.get("/courses?filter[findable]=true&include=accredited_body,provider")
    end

    def select_course_attributes
      data["data"].map do |course|
        @course = course
        {
          name: course_name,
          code: course_code,
          accredited_body_code: accredited_body_code,
          start_date: course_start_date,
          level: course_level,
          age_range: course_age_range,
          duration_in_years: duration_in_years,
          course_length: course_length,
          qualification: course_qualification,
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
        }
      end
    end

    def course_name
      course["attributes"]["name"]
    end

    def course_code
      course["attributes"]["code"]
    end

    def accredited_body_code
      course["attributes"]["accredited_body_code"] || find_accredited_body_code(course)
    end

    def course_start_date
      course["attributes"]["start_date"]
    end

    def course_age_range
      CoursesSpike.age_ranges[age_range(course["attributes"])]
    end

    def course_level
      CoursesSpike.levels[course["attributes"]["level"].to_sym]
    end

    def course_length
      course["attributes"]["course_length"]
    end

    def course_qualification
      CoursesSpike.qualifications[course["attributes"]["qualifications"].sort.join("_with_").to_sym]
    end

    def find_accredited_body_code(course)
      provider_id = course["relationships"]["provider"]["data"]["id"]
      # find the provider code with the provider id
      data["included"].detect { |provider| provider["id"] == provider_id }["attributes"]["code"]
    end

    def age_range(course_attributes)
      age_minimum, age_maximum = course_attributes.values_at("age_minimum", "age_maximum")
      age_maximum = 19 if age_maximum == 18 # DTTP doesn't have an entity with 18
      "#{age_minimum} to #{age_maximum} course"
    end

    def duration_in_years
      case course["attributes"]["course_length"]
      when "OneYear" then 1
      when "TwoYears" then 2
      else 1
      end
    end
  end
end

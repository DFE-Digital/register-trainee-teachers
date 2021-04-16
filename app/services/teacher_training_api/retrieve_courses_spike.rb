# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCoursesSpike
    include ServicePattern

    class Error < StandardError; end
 
    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      select_course_attributes(JSON(response.body)["data"])
    end

  private

    def response
      @response ||= Client.get("/courses")
    end

    def select_course_attributes(ruby_hash_response)
      ruby_hash_response.map do | course |
        {
          name: course["attributes"]["name"],
          code: course["attributes"]["code"],
          accredited_body_code: course["attributes"]["accredited_body_code"],
          start_date: course["attributes"]["start_date"],
          level: course["attributes"]["level"],
          age_range: age_range(course["attributes"]),
          duration_in_years: duration_in_years(course["attributes"]),
          course_length: course["attributes"]["course_length"],
          qualification: course["attributes"]["qualifications"].sort.join("_with_"),
        }
      end
    end

    def age_range(course_attributes)
      age_minimum, age_maximum = course_attributes.values_at("age_minimum", "age_maximum") 
      age_maximum = 19 if age_maximum == 18 # DTTP doesn't have an entity with 18
      "#{age_minimum} to #{age_maximum} course"
    end

    def duration_in_years(course_attributes)
      case course_attributes[:course_length]
      when "OneYear" then 1
      when "TwoYears" then 2
      else 1
      end
    end
  end
end

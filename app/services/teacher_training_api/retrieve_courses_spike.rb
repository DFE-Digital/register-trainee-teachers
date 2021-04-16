# frozen_string_literal: true

module TeacherTrainingApi
  class RetrieveCoursesSpike
    include ServicePattern

    class Error < StandardError; end

    # def initialize
    #   @data = call
    #   @course_attributes = @data
    #   @course_relationships
    # end
 
    def call
      if response.code != 200
        raise Error, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}"
      end

      select_course_attributes(JSON(response.body))
    end

  private

    def response
      @response ||= Client.get("/courses?filter[findable]=true&include=accredited_body,provider")
    end

    def select_course_attributes(data)
      data["data"].map do | course |
        {
          name: course["attributes"]["name"],
          code: course["attributes"]["code"],
          accredited_body_code: accredited_body_code(course, data),
          start_date: course["attributes"]["start_date"],
          level: CoursesSpike.levels[course["attributes"]["level"].to_sym],
          age_range: CoursesSpike.age_ranges[age_range(course["attributes"])],
          duration_in_years: duration_in_years(course["attributes"]),
          course_length: course["attributes"]["course_length"],
          qualification: CoursesSpike.qualifications[course["attributes"]["qualifications"].sort.join("_with_").to_sym],
          created_at: Time.new,
          updated_at: Time.new
        }
      end
    end

    def accredited_body_code(course, data)
      course["attributes"]["accredited_body_code"] || find_accredited_body_code(course, data)
    end

    def find_accredited_body_code(course, data)
      provider_id = course["relationships"]["provider"]["data"]["id"]
      # find the provider code with the provider id
      data["included"].detect{ |provider| provider["id"] == provider_id }["attributes"]["code"]
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

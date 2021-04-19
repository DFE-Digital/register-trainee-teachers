# frozen_string_literal: true

module TeacherTrainingApi
  module Parsers
    class CoursesSpike
      class << self
        def to_course_attributes(data:)
          @data = data
          data["data"].map do |course|
            @course = course

            next if further_education_level_course?

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

      private

        attr_reader :course, :data

        def further_education_level_course?
          course["attributes"]["level"] == "further_education"
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
          Object::CoursesSpike.age_ranges[age_range(course["attributes"])]
        end

        def course_level
          Object::CoursesSpike.levels[course["attributes"]["level"].to_sym]
        end

        def course_length
          course["attributes"]["course_length"] || "course length not provided"
        end

        def course_qualification
          Object::CoursesSpike.qualifications[course["attributes"]["qualifications"].sort.join("_with_").to_sym]
        end

        def find_accredited_body_code(course)
          provider_id = course["relationships"]["provider"]["data"]["id"]
          # find the provider code with the provider id
          data["included"].detect { |provider| provider["id"] == provider_id }["attributes"]["code"]
        end

        def age_range(course_attributes)
          age_minimum, age_maximum = course_attributes.values_at("age_minimum", "age_maximum")
          age_maximum = 19 if age_maximum == 18
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
  end
end

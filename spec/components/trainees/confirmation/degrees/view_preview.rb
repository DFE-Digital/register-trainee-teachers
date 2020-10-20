require "govuk/components"
module Trainees
  module Confirmation
    module Degrees
      class ViewPreview < ViewComponent::Preview
        def with_one_uk_degree
          render_component(Trainees::Confirmation::Degrees::View.new(degrees: single_uk_degree))
        end

        def with_multiple_uk_degree
          render_component(Trainees::Confirmation::Degrees::View.new(degrees: multiple_uk_degrees))
        end

        def with_one_non_uk_degree
          render_component(Trainees::Confirmation::Degrees::View.new(degrees: single_non_uk_degree))
        end

        def with_multiple_non_uk_degree
          render_component(Trainees::Confirmation::Degrees::View.new(degrees: multiple_non_uk_degrees))
        end

        def with_a_mixture_of_uk_and_non_uk_degrees
          render_component(Trainees::Confirmation::Degrees::View.new(degrees: mixture_of_uk_and_non_uk_degrees))
        end

      private

        def mock_uk_degree
          OpenStruct.new(
            uk?: true,
            uk_degree: "BSc - Bachelor of Science",
            degree_subject: "Aviation studies",
            institution: "The Royal College of Nursing",
            graduation_year: "2012",
            degree_grade: "Pass",
          )
        end

        def mock_non_uk_degree
          OpenStruct.new(
            non_uk?: true,
            non_uk_degree: "Ordinary bachelor degree",
            degree_subject: "Clinical dentistry",
            country: "Morocco",
            graduation_year: "1973",
          )
        end

        def single_uk_degree
          @single_uk_degree ||= [mock_uk_degree]
        end

        def multiple_uk_degrees
          @multiple_uk_degrees ||= [
            mock_uk_degree,
            OpenStruct.new(
              uk?: true,
              uk_degree: "BSc Education",
              degree_subject: "Akkadian language",
              institution: "Royal Agricultural University",
              graduation_year: "1973",
              degree_grade: "Third-class honours",
            ),
          ]
        end

        def single_non_uk_degree
          @single_non_uk_degree ||= [mock_non_uk_degree]
        end

        def multiple_non_uk_degrees
          @multiple_non_uk_degrees ||= [
            mock_non_uk_degree,
            OpenStruct.new(
              non_uk?: true,
              non_uk_degree: "Postgraduate certificate or postgraduate diploma",
              degree_subject: "Modern Middle Eastern society and culture studies",
              country: "Afghanistan",
              graduation_year: "2002",
            ),
          ]
        end

        def mixture_of_uk_and_non_uk_degrees
          @mixture_of_uk_and_non_uk_degrees ||= [
            mock_uk_degree,
            mock_non_uk_degree,
          ]
        end
      end
    end
  end
end

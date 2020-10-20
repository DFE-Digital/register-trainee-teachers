module Trainees
  module Confirmation
    module Degrees
      class View < GovukComponent::Base
        attr_accessor :trainee

        def initialize(trainee:)
          @trainee = trainee
        end

        def degree_title(degree)
          if degree.uk?
            "#{degree.uk_degree}: #{degree.degree_subject.downcase}"
          else
            "Non-UK #{degree.non_uk_degree}: #{degree.degree_subject.downcase}"
          end
        end

        def get_degree_rows(degree)
          if degree.uk?
            [
              {
                key: "Degree type",
                value: degree.uk_degree,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> degree type</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Subject",
                value: degree.degree_subject,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Institution",
                value: degree.institution,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> institution</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Graduation year",
                value: degree.graduation_year,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Grade",
                value: degree.degree_grade,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> grade</span>'.html_safe, "http://google.com/"),
              },
            ]
          else
            [
              {
                key: "Comparable UK degree",
                value: degree.non_uk_degree,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> comparable UK degree</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Subject",
                value: degree.degree_subject,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Country",
                value: degree.country,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> institution</span>'.html_safe, "http://google.com/"),
              },
              {
                key: "Graduation year",
                value: degree.graduation_year,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, "http://google.com/"),
              },
            ]
          end
        end
      end
    end
  end
end

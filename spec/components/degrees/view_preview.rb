# frozen_string_literal: true

require "govuk/components"

module Degrees
  class ViewPreview < ViewComponent::Preview
    def with_one_uk_degree
      render(View.new(data_model: mock_trainee(degrees: single_uk_degree)))
    end

    def with_multiple_uk_degree
      render(View.new(data_model: mock_trainee(degrees: multiple_uk_degrees)))
    end

    def with_one_non_uk_degree
      render(View.new(data_model: mock_trainee(degrees: single_non_uk_degree)))
    end

    def with_multiple_non_uk_degree
      render(View.new(data_model: mock_trainee(degrees: multiple_non_uk_degrees)))
    end

    def with_a_mixture_of_uk_and_non_uk_degrees
      render(View.new(data_model: mock_trainee(degrees: mixture_of_uk_and_non_uk_degrees)))
    end

    def with_no_option_to_add_another_degree
      render(
        View.new(
          data_model: mock_trainee(degrees: mixture_of_uk_and_non_uk_degrees),
          show_add_another_degree_button: false,
        ),
      )
    end

    def with_delete_degree_button
      render(
        View.new(
          data_model: mock_trainee(degrees: mixture_of_uk_and_non_uk_degrees),
          show_add_another_degree_button: false,
          show_delete_button: true,
        ),
      )
    end

  private

    def mock_trainee(degrees:)
      Trainee.new(
        id: 0,
        degrees: degrees,
      )
    end

    def mock_uk_degree
      Degree.new(
        id: 0,
        locale_code: :uk,
        uk_degree: "BSc - Bachelor of Science",
        subject: "Aviation studies",
        institution: "The Royal College of Nursing",
        graduation_year: "2012",
        grade: "Pass",
      )
    end

    def mock_non_uk_degree
      Degree.new(
        id: 0,
        locale_code: :non_uk,
        non_uk_degree: "Ordinary bachelor degree",
        subject: "Clinical dentistry",
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
        Degree.new(
          id: 0,
          locale_code: :uk,
          uk_degree: "BSc Education",
          subject: "Akkadian language",
          institution: "Royal Agricultural University",
          graduation_year: "1973",
          grade: "Third-class honours",
        ),
      ]
    end

    def single_non_uk_degree
      @single_non_uk_degree ||= [mock_non_uk_degree]
    end

    def multiple_non_uk_degrees
      @multiple_non_uk_degrees ||= [
        mock_non_uk_degree,
        Degree.new(
          id: 0,
          locale_code: :non_uk,
          non_uk_degree: "Postgraduate certificate or postgraduate diploma",
          subject: "Modern Middle Eastern society and culture studies",
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

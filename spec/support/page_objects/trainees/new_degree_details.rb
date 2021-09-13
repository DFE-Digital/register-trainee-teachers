# frozen_string_literal: true

module PageObjects
  module Trainees
    class NewDegreeDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/new?locale_code={locale_code}"

      element :uk_degree, "#degree-uk-degree-field"
      element :uk_degree_raw, "input[data-nameoriginal='degree[uk_degree_raw]']"

      element :bachelor_degree, "#degree-non-uk-degree-bachelor-degree-field"
      element :ordinary_bachelor_degree, "#degree-non-uk-degree-ordinary-bachelor-degree-field"
      element :bachelor_degree_with_honours, "#degree-non-uk-degree-bachelor-degree-with-honours-field"
      element :postgraduate_certificate_or_postgraduate_diploma, "#degree-non-uk-degree-postgraduate-certificate-or-postgraduate-diploma-field"
      element :master_s_degree_or_integrated_master_s_degree, "#degree-non-uk-degree-master-s-degree-or-integrated-master-s-degree-field"
      element :non_enic, "#degree-non-uk-degree-non-enic-field"

      element :subject, "#degree-subject-field"
      element :subject_raw, "input[data-nameoriginal='degree[subject_raw]']"
      element :institution, "#degree-institution-field"
      element :institution_raw, "input[data-nameoriginal='degree[institution_raw]']"
      element :graduation_year, "#degree-graduation-year-field"
      element :grade, ".degree-grade"
      element :other_grade, "#degree-other-grade-field"

      element :country, "#degree-country-field"
      element :country_raw, "input[data-nameoriginal='degree[country_raw]']"

      element :error_summary, ".govuk-error-summary"
      element :continue, "button[type='submit']"
    end
  end
end

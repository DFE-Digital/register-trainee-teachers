module PageObjects
  module Trainees
    class NewDegreeDetails < PageObjects::Base
      set_url "/trainees/{trainee_id}/degrees/new?locale_code={locale_code}"

      element :uk_degree, "#degree-uk-degree-field"

      element :bachelor_degree, "#degree-non-uk-degree-bachelor-degree-field"
      element :bachelor_ordinary_degree, "#degree-non-uk-degree-bachelor-ordinary-degree-field"
      element :bachelor_honours_degree, "#degree-non-uk-degree-bachelor-honours-degree-field"
      element :postgraduate_certificate_postgraduate_diploma, "#degree-non-uk-degree-postgraduate-certificate-postgraduate-diploma-field"
      element :master_s_degree_integrated_master_s_degree, "#degree-non-uk-degree-master-s-degree-integrated-master-s-degree-field"
      element :non_naric, "#degree-non-uk-degree-non-naric-field"

      element :degree_subject, "#degree-degree-subject-field"
      element :institution, "#degree-institution-field"
      element :graduation_year, "#degree-graduation-year-field"
      element :degree_grade, ".degree-grade"
      element :degree_country, "#degree-country-field"

      element :error_summary, ".govuk-error-summary"
      element :continue, ".govuk-button"
    end
  end
end

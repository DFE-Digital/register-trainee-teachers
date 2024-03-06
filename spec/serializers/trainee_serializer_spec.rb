require "rails_helper"

RSpec.describe TraineeSerializer do
  let(:version) { "0.1" }
  let(:trainee) { create(:trainee) }
  let(:json) { described_class.new(trainee).as_hash.with_indifferent_access }

  TRAINEE_FIELDS = %i[
    id
    ukprn
    trainee_id
    apply_application_id
    trn
    first_names
    middle_names
    last_name
    date_of_birth
    sex
    nationality
    email
    training_route
    submitted_for_trn_at
    updated_at
    course_qualification
    course_level
    course_title
    course_itt_subject
    course_education_phase
    course_study_mode
    course_itt_start_date
    course_age_range
    expected_end_date
    employing_school_urn
    lead_partner_urn_ukprn
    trainee_start_date
  ].freeze

  MORE_FIELDS = %i[
    ethnicity
    other_ethnicity_details
    disability
    other_disability_details

    pga_apprenticeship_start_date

    fund_code
    funding_option


    training_initiative_1
    training_initiative_2
    hesa_husid
    course_title
    candidate_id

  ].freeze

  NOT_NEEDED_OR_NOT_SUPPORTED = %i[
    course_year
    nino
    trainee_previous_surname
  ]

  DEGREE_FIELDS = %i[
    degree_uk_type
    degree_non_uk_type
    degree_graduation_year
    degree_subjects
    degree_uk_grade
    degree_uk_awarding_institution
    degree_country
    degree_non_uk_grade
  ].freeze

  PLACEMENT_FIELDS = %i[
    placement_urn
    placement_school_name
    placement_school_postcode
    placement_urn_free
  ].freeze

  describe "serialization" do
    TRAINEE_FIELDS.each do |field|
      it "serializes the #{field} field from the specification" do
        expect(json).to have_key(field)
      end
    end
  end
end

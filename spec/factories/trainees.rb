# frozen_string_literal: true

FactoryBot.define do
  factory :abstract_trainee, class: "Trainee" do
    transient do
      randomise_subjects { false }
      potential_itt_start_date { itt_start_date || compute_valid_past_itt_start_date }
    end

    sequence :provider_trainee_id do |n|
      year = potential_itt_start_date.strftime("%y").to_i
      "#{year}/#{year + 1}-#{n}"
    end

    provider

    training_route { TRAINING_ROUTE_ENUMS[:assessment_only] }

    first_names { Faker::Name.first_name }
    middle_names { Faker::Name.middle_name }
    last_name { Faker::Name.last_name }
    sex { Trainee.sexes.keys.sample }
    slug { Faker::Alphanumeric.alphanumeric(number: Sluggable::SLUG_LENGTH) }

    diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }
    ethnic_group { nil }
    ethnic_background { nil }
    additional_ethnic_background { nil }
    disability_disclosure { nil }

    start_academic_cycle { AcademicCycle.for_date(itt_start_date) }
    end_academic_cycle { AcademicCycle.for_date(itt_end_date) }

    email { "#{first_names}.#{last_name}@example.com" }
    applying_for_bursary { nil }

    after(:create) do |trainee, _evaluator|
      # NOTE: some of the tests circumvent the proper expectations with associations.
      trainee.reload if trainee.disability_ids.blank? && trainee.trainee_disabilities.present?
    end

    factory :trainee do
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    factory :trainee_for_form do
      transient do
        form_dob { Faker::Date.birthday(min_age: 18, max_age: 65) }
      end
      add_attribute("date_of_birth(3i)") { form_dob.day.to_s }
      add_attribute("date_of_birth(2i)") { form_dob.month.to_s }
      add_attribute("date_of_birth(1i)") { form_dob.year.to_s }
    end

    trait :for_export do
      awarded
      with_tiered_bursary
      with_lead_partner
      with_employing_school
      imported_from_hesa
      with_nationalities
      diversity_disclosure { "diversity_disclosed" }
      ethnic_group { "asian_ethnic_group" }
      disability_disclosure { "disabled" }
      disabled_with_disabilities_disclosed
      training_initiative { "now_teach" }
      itt_start_date { compute_valid_past_itt_start_date }
      itt_end_date { itt_start_date + 2.years }
      with_primary_course_details
    end

    trait :bulk_recommend do
      submitted_for_trn
      trn_received
      with_lead_partner
      with_primary_course_details
    end

    trait :bulk_recommend_from_hesa do
      bulk_recommend
      imported_from_hesa
    end

    trait :with_training_route do
      training_route { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
    end

    trait :without_required_placements do
      with_training_route

      awarded
    end

    trait :with_nationalities do
      nationalities { [Nationality.all.sample || build(:nationality)] }
    end

    trait :with_french_nationality do
      nationalities { [build(:nationality, :french)] }
    end

    trait :without_degrees do
      before(:create) do |trainee|
        trainee.degrees = []
      end
    end

    trait :without_placements do
      before(:create) do |trainee|
        trainee.placements = []
      end
    end

    trait :incomplete do
      provider_trainee_id { nil }
      first_names { nil }
      middle_names { nil }
      last_name { nil }
      sex { nil }
      date_of_birth { nil }

      diversity_disclosure { nil }
      ethnic_group { nil }
      ethnic_background { nil }
      additional_ethnic_background { nil }
      disability_disclosure { nil }

      email { nil }
      trainee_start_date { nil }
    end

    trait :in_progress do
      with_secondary_course_details
      with_start_date
      with_degree
      with_funding
    end

    trait :with_degree do
      degrees { [build(:degree, :uk_degree_with_details)] }
    end

    trait :with_placements do
      has_placement_detail
      placements { create_list(:placement, 2, :with_school) }
    end

    trait :submission_ready do
      submission_ready { true }
    end

    trait :not_submission_ready do
      submission_ready { false }
    end

    trait :completed do
      in_progress
      training_initiative { ROUTE_INITIATIVES_ENUMS.keys.sample }
      applying_for_bursary { false }
      applying_for_scholarship { false }
      applying_for_grant { false }
      nationalities { [Nationality.all.sample || build(:nationality)] }
      # has_placement_detail
      progress do
        Progress.new(
          personal_details: true,
          contact_details: true,
          diversity: true,
          degrees: true,
          course_details: true,
          training_details: true,
          placements: false,
          schools: true,
          funding: true,
          trainee_data: true,
        )
      end
      submission_ready
    end

    trait :submitted_with_start_date do
      submitted_for_trn
      with_start_date
    end

    trait :with_subject_specialism do
      transient do
        subject_name { nil }
      end

      course_subject_one { create(:subject_specialism, subject_name:).name }
    end

    trait :with_primary_education do
      course_education_phase { COURSE_EDUCATION_PHASE_ENUMS[:primary] }
    end

    trait :with_secondary_education do
      course_education_phase { COURSE_EDUCATION_PHASE_ENUMS[:secondary] }
    end

    trait :with_primary_course_details do
      transient do
        primary_specialism_subjects { PUBLISH_PRIMARY_SUBJECT_SPECIALISM_MAPPING.values.sample }
      end
      with_primary_education
      course_subject_one { primary_specialism_subjects.first }
      course_subject_two { primary_specialism_subjects.second }
      course_subject_three { primary_specialism_subjects.third }
      course_age_range do
        age_ranges = DfE::ReferenceData::AgeRanges::AGE_RANGES.all_as_hash
        age_ranges.select do |_, v|
          v[:option] == :main && v[:levels]&.include?(course_education_phase.to_sym)
        end.keys.sample
      end
      with_study_mode_and_course_dates
      course_allocation_subject { create(:subject_specialism, name: course_subject_one)&.allocation_subject }
    end

    trait :with_secondary_course_details do
      with_secondary_education
      course_subject_one do
        if randomise_subjects
          CodeSets::CourseSubjects::MAPPING.keys.reject { |subject| SubjectSpecialism::PRIMARY_SUBJECT_NAMES.include?(subject) }.sample
        else
          CourseSubjects::MATHEMATICS
        end
      end
      course_subject_two { nil }
      course_subject_three { nil }
      course_age_range do
        age_ranges = DfE::ReferenceData::AgeRanges::AGE_RANGES.all_as_hash
        age_ranges.select do |_, v|
          v[:option] == :main && v[:levels]&.include?(course_education_phase.to_sym)
        end.keys.sample
      end
      with_study_mode_and_course_dates
      with_course_allocation_subject
    end

    trait :with_valid_future_itt_start_date do
      itt_start_date { compute_valid_future_itt_start_date }
    end

    trait :with_valid_itt_start_date do
      itt_start_date { compute_valid_past_itt_start_date }
    end

    trait :with_valid_past_itt_start_date do
      itt_start_date { compute_valid_past_itt_start_date }
    end

    trait :with_course_allocation_subject do
      course_allocation_subject { SubjectSpecialism.find_by(name: course_subject_one)&.allocation_subject }
    end

    trait :with_study_mode_and_course_dates do
      study_mode { TRAINEE_STUDY_MODE_ENUMS.keys.sample }
      itt_start_date { compute_valid_past_itt_start_date }
      itt_end_date do
        additional_years = if [2, 9, 10].include?(training_route)
                             3
                           elsif study_mode == "part_time"
                             2
                           else
                             1
                           end
        Faker::Date.in_date_period(month: ACADEMIC_CYCLE_END_MONTH, year: current_academic_year + additional_years)
      end
    end

    trait :with_study_mode_and_future_course_dates do
      study_mode { TRAINEE_STUDY_MODE_ENUMS.keys.sample }
      itt_start_date { Faker::Date.in_date_period(month: ACADEMIC_CYCLE_START_MONTH, year: current_academic_year + 1) }
      itt_end_date do
        additional_years = if [2, 9, 10].include?(training_route)
                             3
                           elsif study_mode == "part_time"
                             2
                           else
                             1
                           end
        Faker::Date.in_date_period(month: ACADEMIC_CYCLE_END_MONTH, year: itt_start_date.year + additional_years)
      end
    end

    trait :with_publish_course_details do
      training_route { TRAINING_ROUTES_FOR_COURSE.keys.sample }
      course_uuid { create(:course_with_subjects, route: training_route, accredited_body_code: provider.code).uuid }
      with_secondary_course_details
    end

    trait :with_start_date do
      trainee_start_date do
        if itt_start_date.present?
          Faker::Date.between(
            from: itt_start_date,
            to: [itt_start_date + rand(20).days, Time.zone.today].min,
          )
        else
          compute_valid_past_itt_start_date
        end
      end
    end

    trait :itt_start_date_in_the_past do
      with_study_mode_and_course_dates
    end

    trait :itt_start_date_in_the_future do
      with_study_mode_and_future_course_dates
    end

    trait :diversity_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] }
    end

    trait :diversity_not_disclosed do
      diversity_disclosure { Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] }
    end

    trait :disability_not_provided do
      disability_disclosure { Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] }
    end

    trait :with_ethnic_group do
      ethnic_group { (Diversities::ETHNIC_GROUP_ENUMS.values - ["not_provided_ethnic_group"]).sample }
    end

    trait :with_ethnic_background do
      ethnic_background { CodeSets::Ethnicities::MAPPING.keys.sample }
    end

    trait :disabled do
      disability_disclosure { Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] }
    end

    trait :disabled_with_disabilities_disclosed do
      disabled
      transient do
        disabilities_count { 1 }
      end

      after(:create) do |trainee, evaluator|
        create_list(:trainee_disability, evaluator.disabilities_count, trainee:)

        if trainee.hesa_trainee_detail.present?
          trainee.hesa_trainee_detail.hesa_disabilities = evaluator.disabilities.map.with_index(1) { |item, index|
            ["disability#{index}", Hesa::CodeSets::Disabilities::MAPPING.key(item.name)]
          }.to_h

          trainee.hesa_trainee_detail.save
        end
        trainee.reload
      end
    end

    trait :with_diversity_information do
      diversity_disclosed
      with_ethnic_group
      with_ethnic_background
      disabled_with_disabilities_disclosed
    end

    trait :with_placement_assignment do
      placement_assignment_dttp_id { SecureRandom.uuid }
    end

    trait :with_outcome_date do
      outcome_date { Faker::Date.in_date_period }
    end

    trait :provider_led_postgrad do
      training_route { TRAINING_ROUTE_ENUMS[:provider_led_postgrad] }
      study_mode { COURSE_STUDY_MODES[:full_time] }
    end

    trait :with_early_years_course_details do
      course_subject_one { CourseSubjects::EARLY_YEARS_TEACHING }
      course_age_range { DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE }
      with_study_mode_and_course_dates
      course_education_phase { COURSE_EDUCATION_PHASE_ENUMS[:early_years] }
    end

    trait :early_years_assessment_only do
      training_route { TRAINING_ROUTE_ENUMS[:early_years_assessment_only] }
      with_early_years_course_details
    end

    trait :early_years_salaried do
      training_route { TRAINING_ROUTE_ENUMS[:early_years_salaried] }
      with_early_years_course_details
    end

    trait :early_years_postgrad do
      training_route { TRAINING_ROUTE_ENUMS[:early_years_postgrad] }
      with_early_years_course_details
    end

    trait :early_years_undergrad do
      training_route { TRAINING_ROUTE_ENUMS[:early_years_undergrad] }
      with_early_years_course_details
    end

    trait :school_direct_tuition_fee do
      training_route { TRAINING_ROUTE_ENUMS[:school_direct_tuition_fee] }
      study_mode { COURSE_STUDY_MODES[:full_time] }
    end

    trait :school_direct_salaried do
      training_route { TRAINING_ROUTE_ENUMS[:school_direct_salaried] }
      study_mode { COURSE_STUDY_MODES[:full_time] }
    end

    trait :opt_in_undergrad do
      training_route { TRAINING_ROUTE_ENUMS[:opt_in_undergrad] }
    end

    trait :iqts do
      training_route { TRAINING_ROUTE_ENUMS[:iqts] }
      iqts_country { CodeSets::Countries::MAPPING.keys.sample }
    end

    trait :draft do
      completed
      state { "draft" }
      submission_ready
    end

    trait :incomplete_draft do
      state { "draft" }
    end

    trait :submitted_for_trn do
      completed
      dttp_id { SecureRandom.uuid }
      submitted_for_trn_at { Time.zone.now }
      state { "submitted_for_trn" }
      submission_ready
    end

    trait :with_dqt_trn_request do
      after(:create) do |trainee|
        create(:dqt_trn_request, trainee:)
      end
    end

    trait :trn_received do
      submitted_for_trn
      trn { Faker::Number.number(digits: 7) }
      state { "trn_received" }
    end

    trait :recommended_for_award do
      trn_received
      outcome_date { Time.zone.now }
      recommended_for_award_at { Time.zone.now }
      state { "recommended_for_award" }
    end

    trait :with_withdrawal_date do
      withdraw_date { Faker::Date.between(from: itt_start_date + 1.day, to: itt_start_date + 1.year) }
    end

    trait :withdrawn do
      trn_received
      with_withdrawal_date

      state { "withdrawn" }

      after(:create) do |trainee|
        create(:trainee_withdrawal, trainee:)
      end
    end

    trait :deferred do
      trn_received
      defer_date { potential_itt_start_date }
      state { "deferred" }
    end

    trait :reinstated do
      completed
      defer_date { potential_itt_start_date }
      reinstate_date { Faker::Date.in_date_period }
      state { "trn_received" }
    end

    trait :awarded do
      recommended_for_award
      state { "awarded" }
      awarded_at { Time.zone.now }
    end

    trait :eyts_awarded do
      training_route { EARLY_YEARS_TRAINING_ROUTES.keys.sample }
      state { "awarded" }
    end

    trait :eyts_recommended do
      training_route { EARLY_YEARS_TRAINING_ROUTES.keys.sample }
      state { "recommended_for_award" }
    end

    trait :qts_awarded do
      training_route { "school_direct_salaried" }
      state { "awarded" }
    end

    trait :qts_recommended do
      training_route { "school_direct_salaried" }
      state { "recommended_for_award" }
    end

    trait :with_dttp_dormancy do
      deferred
      dormancy_dttp_id { SecureRandom.uuid }
    end

    trait :withdrawn_for_specific_reason do
      withdrawn
      withdraw_reasons_details { "withdraw details" }
      withdraw_reasons_dfe_details { "withdraw dfe details" }

      after(:create) do |trainee|
        trainee_withdrawal = create(:trainee_withdrawal, trainee:)
        create(:trainee_withdrawal_reason, trainee:, trainee_withdrawal:)
      end
    end

    trait :withdrawn_for_another_reason do
      withdrawn
      withdraw_reasons_details { "withdraw details" }
      withdraw_reasons_dfe_details { "withdraw dfe details" }

      after(:create) do |trainee|
        withdrawal_reason = create(:withdrawal_reason, name: WithdrawalReasons::ANOTHER_REASON)
        create(:trainee_withdrawal_reason, trainee:, withdrawal_reason:)
      end
    end

    trait :with_related_courses do
      training_route { TRAINING_ROUTES_FOR_COURSE.keys.sample }

      transient do
        courses_count { 5 }
        subject_names { [] }
        study_mode { "full_time" }
        recruitment_cycle_year { Settings.current_recruitment_cycle_year }
      end

      after(:create) do |trainee, evaluator|
        create_list(:course_with_subjects, evaluator.courses_count,
                    subject_names: evaluator.subject_names,
                    accredited_body_code: trainee.provider.code,
                    route: trainee.training_route,
                    study_mode: evaluator.study_mode,
                    recruitment_cycle_year: evaluator.recruitment_cycle_year)

        trainee.reload
      end
    end

    trait :with_lead_partner do
      transient do
        record_type { :school }
      end

      after(:create) do |trainee, evaluator|
        FactoryBot.create(:lead_partner, evaluator.record_type, trainees: [trainee])
      end
    end

    trait :with_lead_partner_scitt do
      transient do
        record_type { :scitt }
      end

      after(:create) do |trainee, evaluator|
        FactoryBot.create(:lead_partner, evaluator.record_type, trainees: [trainee])
      end
    end

    trait :with_employing_school do
      employing_school factory: %i[school]
    end

    trait :with_apply_application do
      record_source { Sourceable::APPLY_SOURCE }
      apply_application
    end

    trait :with_dttp_trainee do
      dttp_trainee
    end

    trait :with_invalid_apply_application do
      degrees { [build(:degree, :uk_degree_with_details, institution: "Unknown institution")] }
      apply_application {
        association(
          :apply_application,
          :with_invalid_data,
          degree_slug: degrees.first.slug,
        )
      }
    end

    trait :with_funding do
      training_initiative { ROUTE_INITIATIVES_ENUMS.keys.sample }
      applying_for_bursary { Faker::Boolean.boolean }
    end

    trait :with_provider_led_bursary do
      transient do
        funding_amount { 100 }
      end

      applying_for_bursary { true }

      after(:create) do |trainee, evaluator|
        funding_method = create(:funding_method, :bursary, :with_subjects, training_route: :provider_led_postgrad, academic_cycle: trainee.start_academic_cycle)
        funding_method.amount = evaluator.funding_amount if evaluator.funding_amount.present?
        funding_method.save

        trainee.course_allocation_subject = funding_method.allocation_subjects.first
        trainee.training_route = funding_method.training_route
        trainee.trainee_start_date = funding_method.academic_cycle.start_date
      end
    end

    trait :with_early_years_grant do
      applying_for_grant { true }

      after(:create) do |trainee, _|
        funding_method = create(:funding_method, :grant, :with_subjects, training_route: :early_years_salaried, academic_cycle: trainee.start_academic_cycle)
        trainee.course_allocation_subject = funding_method.allocation_subjects.first
        trainee.training_route = funding_method.training_route
        trainee.trainee_start_date = funding_method.academic_cycle.start_date
      end
    end

    trait :with_scholarship do
      applying_for_scholarship { true }

      after(:create) do |trainee, _|
        funding_method = create(:funding_method, :scholarship, :with_subjects, training_route: :provider_led_postgrad, academic_cycle: trainee.start_academic_cycle)
        trainee.course_allocation_subject = funding_method.allocation_subjects.first
        trainee.training_route = funding_method.training_route
        trainee.trainee_start_date = funding_method.academic_cycle.start_date
      end
    end

    trait :with_grant do
      transient do
        funding_amount { 100 }
      end

      applying_for_grant { true }

      after(:create) do |trainee, evaluator|
        funding_method = create(:funding_method, :grant, :with_subjects, training_route: :provider_led_postgrad, academic_cycle: trainee.start_academic_cycle)
        funding_method.amount = evaluator.funding_amount if evaluator.funding_amount.present?
        funding_method.save

        trainee.course_allocation_subject = funding_method.allocation_subjects.first
        trainee.training_route = funding_method.training_route
        trainee.trainee_start_date = funding_method.academic_cycle.start_date
      end
    end

    trait :with_grant_and_tiered_bursary do
      transient do
        funding_amount { 5000 }
        start_academic_cycle { association(:academic_cycle, next_cycle: true) }
      end

      early_years_postgrad
      applying_for_grant { true }

      with_tiered_bursary

      after(:create) do |trainee, evaluator|
        trainee.start_academic_cycle = evaluator.start_academic_cycle
        funding_method = create(:funding_method, :grant, :with_subjects, training_route: trainee.training_route, academic_cycle: trainee.start_academic_cycle)

        funding_method.amount = evaluator.funding_amount
        funding_method.save
        trainee.course_allocation_subject = funding_method.allocation_subjects.first

        trainee.trainee_start_date = funding_method.academic_cycle.start_date
      end
    end

    trait :with_tiered_bursary do
      applying_for_bursary { true }
      bursary_tier { BURSARY_TIER_ENUMS[:tier_one] }
    end

    trait :with_hpitt_provider do
      training_route { TRAINING_ROUTE_ENUMS[:hpitt_postgrad] }
      region { CodeSets::Regions::MAPPING.keys.sample }
      provider factory: %i[provider teach_first]
    end

    trait :discarded do
      discarded_at { Time.zone.now }
    end

    trait :created_from_dttp do
      record_source { Sourceable::DTTP_SOURCE }
    end

    trait :created_from_api do
      record_source { Sourceable::API_SOURCE }
    end

    trait :created_manually do
      record_source { Sourceable::MANUAL_SOURCE }
    end

    trait :imported_from_hesa do
      transient do
        itt_aim { Hesa::CodeSets::IttAims::MAPPING.values.sample }
        hesa_student_application_choice_id { nil }
      end

      with_hesa_student
      record_source { Sourceable::HESA_COLLECTION_SOURCE }
      hesa_updated_at { Faker::Time.between(from: 1.month.ago, to: Time.zone.now) }

      after(:create) do |trainee, evaluator|
        create(:hesa_metadatum, trainee: trainee, itt_aim: evaluator.itt_aim)
        if evaluator.hesa_student_application_choice_id.present?
          trainee.hesa_students.first.update!(
            application_choice_id: evaluator.hesa_student_application_choice_id.to_s,
          )
        end
      end
    end

    trait :with_hesa_trainee_detail do
      hesa_id { Faker::Number.number(digits: 13) }
      hesa_trainee_detail
    end

    trait :with_hesa_student do
      hesa_id { Faker::Number.number(digits: 13) }
      hesa_students { create_list(:hesa_student, 1, hesa_id:) }
    end
  end
end

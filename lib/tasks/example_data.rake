# frozen_string_literal: true

require Rails.root.join("config/environment")
require Rails.root.join("spec/support/current_academic_cycle")
require Rails.root.join("spec/support/api_stubs/recruits_api")

# Course names are not all that important here because it's for marketing
# purposes (can be anything). What's important are the subjects associated
# with the course. In a lot of cases, the course name is the same as subject name.
REAL_PUBLISH_COURSES_WITH_SUBJECTS = {
  "Art and design" => ["Art and design"],
  "Biology" => ["Biology"],
  "Business Studies" => ["Business studies"],
  "Chemistry" => ["Chemistry"],
  "Citizenship with Religious education" => ["Citizenship", "Religious education"],
  "Computer Science" => ["Computing"],
  "Dance" => ["Dance"],
  "Design and technology" => ["Design and technology"],
  "Drama (with English)" => %w[Drama English],
  "Drama" => ["Drama"],
  "English" => ["English"],
  "Geography" => ["Geography"],
  "Health and Social Care" => ["Health and social care"],
  "History" => ["History"],
  "Mandarin with French, German, Italian or Spanish" => ["French", "German", "Italian", "Mandarin", "Modern Languages", "Spanish"],
  "Mathematics" => ["Mathematics"],
  "Media Studies with English" => ["Communication and media studies", "English"],
  "Modern Languages (French and Spanish)" => %w[French Spanish],
  "Modern Languages (French and/or Spanish)" => %w[French Spanish],
  "Modern Languages (German and Spanish)" => %w[German Spanish],
  "Modern Languages (German)" => ["German", "Modern languages (other)"],
  "Modern Languages (Spanish)" => %w[Spanish],
  "Modern Languages" => ["French", "German", "Italian", "Mandarin", "Modern Languages", "Spanish"],
  "Music" => %w[Music],
  "Other Modern Languages" => ["Modern languages (other)"],
  "PE with EBacc" => ["Physical education"],
  "Physical Education" => ["Physical education"],
  "Physics" => ["Physics"],
  "Primary (Physical Education)" => ["Primary with physical education"],
  "Primary with English" => ["Primary with English"],
  "Primary with Mathematics" => ["Primary with mathematics"],
  "Primary with geography and history" => ["Primary with geography and history"],
  "Primary with modern languages" => ["Primary with modern languages"],
  "Primary with science" => ["Primary with science"],
  "Primary" => ["Primary"],
  "Psychology" => ["Psychology"],
  "Religious education" => ["Religious education"],
  "Social Sciences" => ["Social sciences"],
}.freeze

HESA_TRAINING_ROUTES = Hesa::CodeSets::TrainingRoutes::MAPPING.values.freeze

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    if Trainee.any?
      puts "Noop as DB already contains data"
      exit
    end

    # Running `bundle exec rails db:migrate db:seed example_data:generate` can sometimes use cached column information.
    # This forces rails to reload column information before attempting to generate factories
    Trainee.reset_column_information

    Faker::Config.locale = "en-GB"

    # Base our example data on the currently switched-on feature flags
    enabled_routes = TRAINING_ROUTE_FEATURE_FLAGS.select { |flag| FeatureService.enabled?("routes.#{flag}") }
                                                 .compact
                                                 .push(:assessment_only)
    enabled_course_routes = enabled_routes & TRAINING_ROUTES_FOR_COURSE.keys.map(&:to_sym)

    # Create some schools
    employing_schools = FactoryBot.create_list(:school, 50)

    # Create some lead partners
    lead_partners = FactoryBot.create_list(:lead_partner, 50, :school)

    # Create some subjects
    REAL_PUBLISH_COURSES_WITH_SUBJECTS.values.flatten.uniq.map { |name| FactoryBot.create(:subject, name:) }

    recruitment_cycle_years = [
      Settings.current_recruitment_cycle_year - 1,
      Settings.current_recruitment_cycle_year,
      Settings.current_recruitment_cycle_year + 1,
    ]

    # For each persona...
    PERSONAS.each do |persona_attributes|
      # Create the persona
      persona = Persona.create_with(dttp_id: SecureRandom.uuid).find_or_create_by!(
        first_name: persona_attributes[:first_name],
        last_name: persona_attributes[:last_name],
        email: persona_attributes[:email],
        system_admin: persona_attributes[:system_admin],
      )

      next unless persona_attributes[:provider]

      # Create the provider for that persona
      provider = FactoryBot.create(
        :provider,
        :with_dttp_id,
        name: persona_attributes[:provider],
        code: persona_attributes[:provider_code].presence || Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      )

      ProviderUser.find_or_create_by!(user: persona, provider: provider)
      FactoryBot.create(:payment_schedule, :for_full_year, payable: provider)
      FactoryBot.create(:trainee_summary, :with_bursary_and_scholarship_and_multiple_amounts, payable: provider)

      FactoryBot.create(:authentication_token, :revoked, provider: provider, revoked_by: persona)
      FactoryBot.create(:authentication_token, provider: provider, last_used_at: 1.day.ago)
      FactoryBot.create(:authentication_token, :will_expire, provider:)
      FactoryBot.create(:authentication_token, :expired, provider:)

      if persona_attributes[:lead_partner]
        lead_partner = lead_partners.sample
        LeadPartnerUser.create!(user: persona, lead_partner: lead_partner)
        FactoryBot.create(:payment_schedule, :for_full_year, payable: lead_partner.school)
        FactoryBot.create(:trainee_summary, :with_grant_rows, payable: lead_partner.school)
      end

      # For each of the course routes enabled...
      enabled_course_routes.each do |route|
        REAL_PUBLISH_COURSES_WITH_SUBJECTS.each do |course_name, subject_names|
          recruitment_cycle_years.each do |recruitment_cycle_year|
            FactoryBot.build(
              :course,
              accredited_body_code: provider.code,
              published_start_date: Date.new(recruitment_cycle_year, 9, 1),
              route: route,
              name: course_name,
              level: course_name.include?("Primary") ? :primary : :secondary,
              study_mode: COURSE_STUDY_MODE_ENUMS.keys.sample,
              recruitment_cycle_year: recruitment_cycle_year,
            ) { |course|
              course.subjects = Subject.where(name: subject_names)
            }.save!
          end
        end
      end

      # Hpitt provider can only have trainees on the hpitt_postgrad route
      enabled_routes = [TRAINING_ROUTE_ENUMS[:hpitt_postgrad]] if provider.hpitt_postgrad?

      nationalities = Nationality.all

      # For each route that's enabled...
      enabled_routes.each do |route|
        # And for all possible trainee states...
        Trainee.states.keys.map(&:to_sym).each do |state|
          # Create small number of trainees
          sample_size = rand(4...8)

          sample_size.times do |sample_index|
            nationalities = [nationalities.sample]

            if sample_index < sample_size * 20.0 / 100 # Give 20% of trainees an extra nationality and a non-uk degree
              nationalities << nationalities.sample
              degree_type = :non_uk_degree_with_details
            else
              degree_type = :uk_degree_with_details
            end

            attrs = {
              randomise_subjects: true,
              created_at: Faker::Date.between(from: 100.days.ago, to: 50.days.ago),
              nationalities: nationalities,
              degrees: [FactoryBot.build(:degree, degree_type)],
            }
            attrs.merge!(provider:) if provider

            # Some route-specific logic, but could move into factories too
            attrs.merge!(employing_school: employing_schools.sample) if EMPLOYING_SCHOOL_ROUTES.include?(route)

            if enabled_course_routes.include?(route)

              courses = provider.courses.where(route:)

              if state == :draft
                # Make *roughly* half of draft trainees apply drafts
                if sample_index >= sample_size / 2
                  # Create apply drafts for *next* academic cycle
                  courses = courses.where(recruitment_cycle_year: Settings.current_recruitment_cycle_year + 1)

                  attrs.merge!(
                    apply_application: FactoryBot.build(:apply_application, accredited_body_code: provider.code),
                  )
                else
                  # Create manual drafts for *current* academic cycle
                  courses = courses.where(recruitment_cycle_year: Settings.current_recruitment_cycle_year)
                end
              end

              course = courses.sample

              if course.present?
                course_subject_one, course_subject_two, course_subject_three = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name)).values.map(&:first).compact

                attrs.merge!(
                  course_uuid: course.uuid,
                  course_education_phase: course.level,
                  course_subject_one: course_subject_one,
                  course_subject_two: course_subject_two,
                  course_subject_three: course_subject_three,
                  study_mode: TRAINEE_STUDY_MODE_ENUMS[course.study_mode] || TRAINEE_STUDY_MODE_ENUMS.keys.sample,
                  course_min_age: course.min_age,
                  course_max_age: course.max_age,
                  itt_start_date: course.published_start_date,
                  itt_end_date: course.published_start_date + 9.months,
                )
              end

            end

            # Make *roughly* 25% of submitted_for_trn trainees not have a trainee start date
            if state == :submitted_for_trn && sample_index < sample_size * 25.0 / 100
              attrs.merge!(trainee_start_date: nil)
            end

            # Make 75% of drafts (both apply and manual) incomplete
            if state == :draft && (sample_index < sample_size * 75.0 / 100)
              attrs.merge!(
                progress: Progress.new,
                submission_ready: false,
                itt_start_date: nil,
                itt_end_date: nil,
                provider_trainee_id: nil,
                employing_school: nil,
              )
            end

            if route.to_s.include?(EARLY_YEARS_ROUTE_NAME_PREFIX)
              attrs.merge!(
                course_subject_one: CourseSubjects::EARLY_YEARS_TEACHING,
                course_age_range: DfE::ReferenceData::AgeRanges::ZERO_TO_FIVE,
                course_education_phase: nil,
              )
            end

            # Ensure no subjects are set on apply applications - this means that
            # the user is required to confirm the course.
            if attrs[:apply_application].present?
              attrs.merge!(
                course_subject_one: nil,
                course_subject_two: nil,
                course_subject_three: nil,
              )
            end

            if provider.name.include?(PROVIDER_C) && HESA_TRAINING_ROUTES.include?(route.to_s) && state != :draft
              trainee = FactoryBot.create(:trainee, route, state, :imported_from_hesa, attrs)
              if sample_index < sample_size * 50.0 / 100
                trainee.record_source = Sourceable::DTTP_SOURCE
                trainee.created_from_hesa = false
              end
            else
              trainee = FactoryBot.create(:trainee, route, state, attrs)
            end

            if sample_index < sample_size * 80.0 / 100
              funding_manager = FundingManager.new(trainee)

              trainee.applying_for_bursary = true if funding_manager.can_apply_for_bursary?
              trainee.applying_for_grant = true if funding_manager.can_apply_for_grant?
              trainee.applying_for_scholarship = true if funding_manager.can_apply_for_scholarship?
            end

            # Make *roughly* 10% of a persona's awarded trainees applicable for placement
            if state == :awarded && sample_index < sample_size * 10.0 / 100
              trainee.trn = Faker::Number.number(digits: 7)
            end

            FormStore.clear_all(trainee.id)
            trainee.save!

            # Make *roughly* 75% of submitted_for_trn trainees have trainee withdraw reason
            if state == :withdrawn && sample_index < sample_size * 75.0 / 100
              trainee.withdrawal_reasons << WithdrawalReason.find_by_name(WithdrawalReasons::REASONS.sample)
            end
          end
        end
      end
    end

    # We don't want all trainees having the same update date on the index page
    Audited.audit_class.find_each do |audit|
      random_date = rand(100).days.ago
      audit.update(created_at: random_date)
      audit.auditable.tap do |auditable|
        if auditable.is_a?(Trainee)
          auditable.created_at = random_date
          auditable.updated_at = random_date
          auditable.save(touch: false)
        end
      end
    end
  end

  desc "Create a smaller set of personas, providers and trainees (approx 10% of full size)"
  task generate_light: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Trainee.reset_column_information
    Faker::Config.locale = "en-GB"

    enabled_routes = TRAINING_ROUTE_FEATURE_FLAGS.select { |flag| FeatureService.enabled?("routes.#{flag}") }
      .compact
      .push(:assessment_only)
    enabled_course_routes = enabled_routes & TRAINING_ROUTES_FOR_COURSE.keys.map(&:to_sym)

    lead_partners = FactoryBot.create_list(:lead_partner, 5, :school)

    REAL_PUBLISH_COURSES_WITH_SUBJECTS.values.flatten.uniq.map { |name| FactoryBot.create(:subject, name:) }

    PERSONAS.take(2).each do |persona_attributes| # only 2 personas instead of all
      persona = Persona.create_with(dttp_id: SecureRandom.uuid).find_or_create_by!(
        first_name: persona_attributes[:first_name],
        last_name: persona_attributes[:last_name],
        email: persona_attributes[:email],
        system_admin: persona_attributes[:system_admin],
      )

      next unless persona_attributes[:provider]

      provider = FactoryBot.create(
        :provider,
        :with_dttp_id,
        name: persona_attributes[:provider],
        code: persona_attributes[:provider_code].presence || Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      )

      ProviderUser.find_or_create_by!(user: persona, provider: provider)
      FactoryBot.create(:payment_schedule, :for_full_year, payable: provider)
      FactoryBot.create(:trainee_summary, :with_bursary_and_scholarship_and_multiple_amounts, payable: provider)

      FactoryBot.create(:authentication_token, provider:)

      if persona_attributes[:lead_partner]
        lead_partner = lead_partners.sample
        LeadPartnerUser.create!(user: persona, lead_partner: lead_partner)
      end

      enabled_course_routes.each do |route|
        REAL_PUBLISH_COURSES_WITH_SUBJECTS.first(5).each do |course_name, subject_names|
          FactoryBot.build(
            :course,
            accredited_body_code: provider.code,
            published_start_date: Date.new(Settings.current_recruitment_cycle_year, 9, 1),
            route: route,
            name: course_name,
            level: course_name.include?("Primary") ? :primary : :secondary,
            study_mode: COURSE_STUDY_MODE_ENUMS.keys.sample,
            recruitment_cycle_year: Settings.current_recruitment_cycle_year,
          ) { |course|
            course.subjects = Subject.where(name: subject_names)
          }.save!
        end
      end

      nationalities = Nationality.all

      enabled_routes.each do |route|
        %i[draft submitted_for_trn awarded].each do |state|
          sample_size = rand(1..2)

          sample_size.times do
            attrs = {
              nationalities: [nationalities.sample],
              degrees: [FactoryBot.build(:degree, :uk_degree_with_details)],
              provider: provider,
            }

            course = provider.courses.where(route:).sample
            if course
              attrs.merge!(
                course_uuid: course.uuid,
                itt_start_date: course.published_start_date,
                itt_end_date: course.published_start_date + 9.months,
              )
            end

            trainee = FactoryBot.create(:trainee, route, state, attrs)
            FormStore.clear_all(trainee.id)
          end
        end
      end
    end
  end
end

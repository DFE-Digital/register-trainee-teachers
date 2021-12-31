# frozen_string_literal: true

require Rails.root.join("spec/support/api_stubs/apply_api")

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
    lead_schools = FactoryBot.create_list(:school, 50, lead_school: true)

    # Create some subjects
    REAL_PUBLISH_COURSES_WITH_SUBJECTS.values.flatten.uniq.map { |name| FactoryBot.create(:subject, name: name) }

    # For each persona...
    PERSONAS.each do |persona_attributes|
      # Create the persona
      persona = Persona.create_with(dttp_id: SecureRandom.uuid).find_or_create_by!(first_name: persona_attributes[:first_name],
                                                                                   last_name: persona_attributes[:last_name],
                                                                                   email: persona_attributes[:email],
                                                                                   system_admin: persona_attributes[:system_admin])

      next unless persona_attributes[:provider]

      # Create the provider for that persona
      provider = Provider.create_with(dttp_id: SecureRandom.uuid).find_or_create_by!(
        name: persona_attributes[:provider],
        code: persona_attributes[:provider_code].presence || Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      )

      persona.update!(provider: provider)

      # For each of the course routes enabled...
      enabled_course_routes.each do |route|
        REAL_PUBLISH_COURSES_WITH_SUBJECTS.each_with_index do |(course_name, subject_names), index|
          FactoryBot.build(
            :course,
            accredited_body_code: provider.code,
            published_start_date: index.even? ? Time.zone.now : 1.month.from_now,
            route: route,
            name: course_name,
            level: course_name.include?("Primary") ? :primary : :secondary,
            study_mode: TRAINEE_STUDY_MODE_ENUMS.keys.sample,
            recruitment_cycle_year: Time.zone.today.year,
          ) { |course|
            course.subjects = Subject.where(name: subject_names)
          }.save!

          # Last cycle year
          if SecureRandom.random_number(100) > 50
            FactoryBot.build(
              :course,
              accredited_body_code: provider.code,
              published_start_date: index.even? ? Time.zone.now : 1.month.from_now,
              route: route,
              name: course_name,
              level: course_name.include?("Primary") ? :primary : :secondary,
              study_mode: TRAINEE_STUDY_MODE_ENUMS.keys.sample,
              recruitment_cycle_year: 1.year.ago.year,
            ) { |course|
              course.subjects = Subject.where(name: subject_names)
            }.save!
          end

          # Next cycle year
          next unless SecureRandom.random_number(100) > 50

          FactoryBot.build(
            :course,
            accredited_body_code: provider.code,
            published_start_date: index.even? ? Time.zone.now : 1.month.from_now,
            route: route,
            name: course_name,
            level: course_name.include?("Primary") ? :primary : :secondary,
            study_mode: TRAINEE_STUDY_MODE_ENUMS.keys.sample,
            recruitment_cycle_year: 1.year.from_now.year,
          ) { |course|
            course.subjects = Subject.where(name: subject_names)
          }.save!
        end
      end

      # Hpitt provider can only have trainees on the hpitt_postgrad route
      enabled_routes = [TRAINING_ROUTE_ENUMS[:hpitt_postgrad]] if provider.hpitt_postgrad?

      # For each route that's enabled...
      enabled_routes.each do |route|
        # And for all possible trainee states...
        Trainee.states.keys.map(&:to_sym).each do |state|
          # Create small number of trainees
          sample_size = rand(4...8)

          sample_size.times do |sample_index|
            attrs = { randomise_subjects: true, created_at: Faker::Date.between(from: 100.days.ago, to: 50.days.ago) }
            attrs.merge!(provider: provider) if provider

            # Some route-specific logic, but could move into factories too
            attrs.merge!(lead_school: lead_schools.sample) if LEAD_SCHOOL_ROUTES.include?(route)
            attrs.merge!(employing_school: employing_schools.sample) if EMPLOYING_SCHOOL_ROUTES.include?(route)

            if state != :draft
              course = provider.courses.where(route: TRAINING_ROUTES_FOR_COURSE[route.to_s]).sample

              if course
                course_subject_one, course_subject_two, course_subject_three = CalculateSubjectSpecialisms.call(subjects: course.subjects.pluck(:name)).values.map(&:first).compact

                attrs.merge!(
                  course_uuid: course.uuid,
                  course_education_phase: course.level,
                  course_subject_one: course_subject_one,
                  course_subject_two: course_subject_two,
                  course_subject_three: course_subject_three,
                  study_mode: TRAINEE_STUDY_MODE_ENUMS[course.study_mode],
                  course_min_age: course.min_age,
                  course_max_age: course.max_age,
                  itt_start_date: course.published_start_date,
                  itt_end_date: course.end_date,
                )
              end
            end

            # Make *roughly* half of draft trainees apply drafts
            if state == :draft && sample_index < sample_size / 2 && enabled_course_routes.include?(route)
              attrs.merge!(course_uuid: provider.courses.where(route: route).pluck(:uuid).sample,
                           apply_application: FactoryBot.create(:apply_application, accredited_body_code: provider.code))
            end

            if route.to_s.include?(EARLY_YEARS_ROUTE_NAME_PREFIX)
              attrs.merge!(
                course_subject_one: CourseSubjects::EARLY_YEARS_TEACHING,
                course_age_range: AgeRange::ZERO_TO_FIVE,
              )
            end

            trainee = FactoryBot.create(:trainee, route, state, attrs)

            # Add an extra nationality 20% of the time
            trainee.nationalities << Nationality.all.sample if rand(10) < 2
          end
        end
      end
    end
  end
end

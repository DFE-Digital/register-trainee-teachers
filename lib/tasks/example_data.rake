# frozen_string_literal: true

require "faker"
require "factory_bot"

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    employing_schools = FactoryBot.create_list(:school, 50)
    lead_schools = FactoryBot.create_list(:school, 50, lead_school: true)

    enabled_routes = TRAINING_ROUTE_FEATURE_FLAGS.map { |flag| flag if FeatureService.enabled?("routes.#{flag}") }.compact.push(:assessment_only)

    enabled_course_routes = enabled_routes & TRAINING_ROUTES_FOR_COURSE.keys.map(&:to_sym)

    available_traits = enabled_routes.map { |route|
      trainee = Trainee.new(training_route: route)

      [
        route,
        {
          personal_details: %i[with_personal_details manually_add_nationality],
          contact_details: %i[with_uk_contact_details],
          training_details: %i[with_trainee_id with_start_date],
        },

        degrees: %i[manually_add_degrees],
        course_details: %i[with_related_course_details],
        placement_details: [*(:with_placement_assignment if trainee.requires_placement_details?)],
        schools: [*(:manually_add_lead_school if trainee.requires_schools?), *(:manually_add_employing_school if trainee.requires_schools?)],
      ]
    }.product(%i[diversity_disclosed diversity_not_disclosed]).map(&:flatten)

    states = %i[draft
                submitted_for_trn
                trn_received
                recommended_for_award
                withdrawn
                deferred
                awarded]

    default_trait_combinations = (states.flat_map do |state|
      available_traits.map do |route, default_traits, other_traits, diversity_trait|
        non_draft = state != :draft

        all_traits = default_traits.merge(other_traits)

        all_traits_values = all_traits.values.flatten
        traits = [state, diversity_trait] + all_traits_values.reject { |trait| trait.start_with?("manually_add_") }

        manual_traits = all_traits_values - traits

        progress = all_traits.to_h { |k, v| [k, non_draft || v.any?] }
        [route,  traits, manual_traits, progress]
      end
    end).group_by(&:first).to_h

    trainees_to_create = enabled_routes.flat_map { |route| default_trait_combinations[route] + [*0..(rand(1..12))].map { default_trait_combinations[route].sample } }

    subjects = Dttp::CodeSets::CourseSubjects::MAPPING.keys.map { |name| FactoryBot.build(:subject, name: name) }

    PERSONAS.each do |persona_attributes|
      persona = Persona.find_or_create_by!(first_name: persona_attributes[:first_name],
                                           last_name: persona_attributes[:last_name],
                                           email: persona_attributes[:email],
                                           dttp_id: SecureRandom.uuid,
                                           system_admin: persona_attributes[:system_admin])

      next unless persona_attributes[:provider]

      provider = Provider.find_or_create_by!(
        name: persona_attributes[:provider],
        dttp_id: SecureRandom.uuid,
        code: Faker::Alphanumeric.alphanumeric(number: 3).upcase,
      )

      enabled_course_routes.each do |route|
        FactoryBot.build_list(:course, rand(10..100), accredited_body_code: provider.code, route: route) { |course|
          course.subjects = subjects.sample(rand(1..3))
        }.each(&:save!)
      end

      persona.update!(provider: provider)

      trainees_to_create.each do |training_route, traits, manual_traits, progress|
        nationalities = []
        if manual_traits.include?(:manually_add_nationality)
          nationalities = Nationality.all.sample([1, 1, 1, 1, 1, 2].sample)
        end

        degrees = []
        if manual_traits.include?(:manually_add_degrees)
          [1, 2].sample.times do
            degrees << FactoryBot.build(:degree, %i[uk_degree_with_details non_uk_degree_with_details].sample)
          end
        end

        employing_school = nil
        if manual_traits.include?(:manually_add_employing_school)
          employing_school = employing_schools.sample
        end

        lead_school = nil
        if manual_traits.include?(:manually_add_lead_school)
          lead_school = lead_schools.sample
        end

        trainee_attributes = {
          progress: progress,
          training_route: training_route,
          nationalities: nationalities,
          degrees: degrees,
          provider: provider,
          employing_school: employing_school,
          lead_school: lead_school,
        }

        FactoryBot.create(:trainee, *traits, trainee_attributes)
      end
    end
  end
end

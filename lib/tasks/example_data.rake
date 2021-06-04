# frozen_string_literal: true

require "faker"
require "factory_bot"

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    FactoryBot.create_list(:school, 50)
    FactoryBot.create_list(:school, 50, lead_school: true)

    default_trait_combinations = [
      # draft
      %i[draft],
      %i[draft with_start_date with_course_details_wip diversity_disclosed],
      %i[draft with_start_date with_course_details_wip diversity_not_disclosed],
      # submitted_for_trn
      %i[submitted_for_trn with_start_date with_placement_assignment with_course_details_wip diversity_disclosed],
      %i[submitted_for_trn with_start_date with_placement_assignment with_course_details_wip diversity_not_disclosed],
      # trn_received
      %i[trn_received with_start_date with_placement_assignment with_course_details_wip diversity_disclosed],
      %i[trn_received with_start_date with_placement_assignment with_course_details_wip diversity_not_disclosed],
      # recommend_for_award
      %i[recommended_for_award with_start_date with_placement_assignment with_outcome_date with_course_details_wip diversity_disclosed],
      %i[recommended_for_award with_start_date with_placement_assignment with_outcome_date with_course_details_wip diversity_not_disclosed],
      # withdrawn
      %i[withdrawn with_start_date with_placement_assignment with_course_details_wip diversity_disclosed],
      %i[withdrawn with_start_date with_placement_assignment with_course_details_wip diversity_not_disclosed],
      # deferred
      %i[deferred with_start_date with_placement_assignment with_course_details_wip diversity_disclosed],
      %i[deferred with_start_date with_placement_assignment with_course_details_wip diversity_not_disclosed],
      # awarded
      %i[awarded with_start_date with_placement_assignment with_outcome_date with_course_details_wip diversity_disclosed],
      %i[awarded with_start_date with_placement_assignment with_outcome_date with_course_details_wip diversity_not_disclosed],
    ].freeze

    enabled_routes = TRAINING_ROUTE_FEATURE_FLAGS.map { |flag| flag if FeatureService.enabled?("routes.#{flag}") }.compact.push(:assessment_only)
    enabled_course_routes = enabled_routes & TRAINING_ROUTES_FOR_COURSE.keys.map(&:to_sym)

    trainees_to_create = enabled_routes.map { |route| [route] << default_trait_combinations + [*0..(rand(1..3))].map { default_trait_combinations.sample } }

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
        FactoryBot.create_list(:course, rand(3..7), accredited_body_code: provider.code, route: route)
      end

      persona.update!(provider: provider)

      trainees_to_create.each do |training_route, traits_combinations|
        traits_combinations.each do |traits|
          created_at = Faker::Date.between(from: 100.days.ago, to: 50.days.ago)
          submitted_for_trn_at = nil
          trn = nil
          progress = {}

          unless traits.include?(:draft)
            # mark the sections complete
            progress = {
              personal_details: true,
              contact_details: true,
              degrees: true,
              diversity: true,
              course_details: true,
              training_details: true,
            }

            # set the submitted_for_trn_at date as they will have at least been submitted
            submitted_for_trn_at = traits.any? ? Faker::Date.between(from: created_at, to: created_at + 40.days) : nil

            unless traits.include?(:submitted_for_trn)
              # this trainee is past getting trn so set it
              trn = Faker::Number.number(digits: 10)
            end
          end

          trainee_attributes = {
            created_at: created_at,
            submitted_for_trn_at: submitted_for_trn_at,
            trn: trn,
            progress: progress,
            updated_at: submitted_for_trn_at || created_at,
            training_route: training_route,
          }

          trainee_attributes.merge!(provider: provider) if provider

          trainee = FactoryBot.create(:trainee, *traits, trainee_attributes)

          [1, 1, 1, 1, 1, 2].sample.times do # multiple nationalities are less common
            trainee.nationalities << Nationality.all.sample
          end

          next if trainee.draft?

          [1, 2].sample.times do
            trainee.degrees << FactoryBot.build(:degree, %i[uk_degree_with_details non_uk_degree_with_details].sample)
          end
        end
      end
    end
  end
end

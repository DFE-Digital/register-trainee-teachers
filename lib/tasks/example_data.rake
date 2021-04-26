# frozen_string_literal: true

require "faker"
require "factory_bot"

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    FactoryBot.create_list(:school, 50, lead_school: true)

    PERSONAS.each do |persona_attributes|
      persona = Persona.find_or_create_by!(first_name: persona_attributes[:first_name],
                                           last_name: persona_attributes[:last_name],
                                           email: persona_attributes[:email],
                                           dttp_id: SecureRandom.uuid,
                                           system_admin: persona_attributes[:system_admin])

      if persona_attributes[:provider]
        provider = Provider.find_or_create_by!(
          name: persona_attributes[:provider],
          dttp_id: SecureRandom.uuid,
          code: Faker::Alphanumeric.alphanumeric(number: 3).upcase,
        )
        persona.update!(provider: provider)
      end

      trait_combinations = [
        [],
        %i[with_start_date with_course_details diversity_disclosed],
        %i[with_start_date with_course_details diversity_not_disclosed],
        %i[with_start_date submitted_for_trn with_placement_assignment with_course_details diversity_disclosed],
        %i[with_start_date submitted_for_trn with_placement_assignment with_course_details diversity_not_disclosed],
        %i[with_start_date trn_received with_placement_assignment with_course_details diversity_disclosed],
        %i[with_start_date trn_received with_placement_assignment with_course_details diversity_not_disclosed],
        %i[with_start_date recommended_for_award with_placement_assignment with_outcome_date with_course_details diversity_disclosed],
        %i[with_start_date recommended_for_award with_placement_assignment with_outcome_date with_course_details diversity_not_disclosed],
        %i[with_start_date withdrawn with_placement_assignment with_course_details diversity_disclosed],
        %i[with_start_date withdrawn with_placement_assignment with_course_details diversity_not_disclosed],
        %i[with_start_date deferred with_placement_assignment with_course_details diversity_disclosed],
        %i[with_start_date deferred with_placement_assignment with_course_details diversity_not_disclosed],
        %i[with_start_date awarded with_placement_assignment with_outcome_date with_course_details diversity_disclosed],
        %i[with_start_date awarded with_placement_assignment with_outcome_date with_course_details diversity_not_disclosed],
      ]

      rand(50...100).times do
        traits = trait_combinations.sample

        created_at = Faker::Date.between(from: 100.days.ago, to: 50.days.ago)
        submitted_for_trn_at = nil
        trn = nil
        progress = {}

        if traits.length > 3 # this trainee isn't draft

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

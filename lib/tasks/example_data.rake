# frozen_string_literal: true

require "faker"
require "factory_bot"

namespace :example_data do
  desc "Create personas, their providers and a selection of trainees"
  task generate: :environment do
    raise "THIS TASK CANNOT BE RUN IN PRODUCTION" if Rails.env.production?

    Faker::Config.locale = "en-GB"

    PERSONAS.each do |persona|
      provider = Provider.find_or_create_by!(name: persona[:provider])

      Persona.find_or_create_by!(first_name: persona[:first_name],
                                 last_name: persona[:last_name],
                                 email: persona[:email],
                                 provider: provider)

      trait_combinations = [
        [],
        %i[with_programme_details diversity_disclosed],
        %i[with_programme_details diversity_not_disclosed],
        %i[submitted_for_trn with_placement_assignment with_programme_details diversity_disclosed],
        %i[submitted_for_trn with_placement_assignment with_programme_details diversity_not_disclosed],
        %i[trn_received with_placement_assignment with_programme_details diversity_disclosed],
        %i[trn_received with_placement_assignment with_programme_details diversity_not_disclosed],
        %i[recommended_for_qts with_placement_assignment with_outcome_date with_programme_details diversity_disclosed],
        %i[recommended_for_qts with_placement_assignment with_outcome_date with_programme_details diversity_not_disclosed],
        %i[withdrawn with_placement_assignment with_programme_details diversity_disclosed],
        %i[withdrawn with_placement_assignment with_programme_details diversity_not_disclosed],
        %i[deferred with_placement_assignment with_programme_details diversity_disclosed],
        %i[deferred with_placement_assignment with_programme_details diversity_not_disclosed],
        %i[qts_awarded with_placement_assignment with_outcome_date with_programme_details diversity_disclosed],
        %i[qts_awarded with_placement_assignment with_outcome_date with_programme_details diversity_not_disclosed],
      ]

      rand(50...100).times do
        traits = trait_combinations.sample

        created_at = Faker::Date.between(from: 100.days.ago, to: 50.days.ago)
        submitted_for_trn_at = nil
        trn = nil
        progress = {}

        if traits.length > 2 # this trainee isn't draft

          # mark the sections complete
          progress = {
            personal_details: true,
            contact_details: true,
            degrees: true,
            diversity: true,
            programme_details: true,
          }

          # set the submitted_for_trn_at date as they will have at least been submitted
          submitted_for_trn_at = traits.any? ? Faker::Date.between(from: created_at, to: created_at + 40.days) : nil

          unless traits.include?(:submitted_for_trn)
            # this trainee is past getting trn so set it
            trn = Faker::Number.number(digits: 10)
          end
        end

        updated_at = submitted_for_trn_at || created_at

        trainee = FactoryBot.create(
          :trainee,
          *traits,
          provider: provider,
          created_at: created_at,
          submitted_for_trn_at: submitted_for_trn_at,
          trn: trn,
          progress: progress,
          updated_at: updated_at,
        )

        [1, 1, 1, 1, 1, 2].sample.times do # multiple nationalities are less common
          trainee.nationalities << FactoryBot.build(:nationality)
        end

        next if trainee.draft?

        [1, 2].sample.times do
          trainee.degrees << FactoryBot.build(:degree, %i[uk_degree_with_details non_uk_degree_with_details].sample)
        end
      end
    end
  end
end

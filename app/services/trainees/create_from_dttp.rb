# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
    end

    def call
      return if provider.blank?
      return if placement_assignment.blank?

      if trainee_already_exists?
        dttp_trainee.non_processable_duplicate!
        return
      end

      trainee = Trainee.new(mapped_attributes)

      trainee.save!

      # TODO: TBC what states are we going to use
      dttp_trainee.processed!

      trainee
    end

  private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      {
        provider: provider,
        first_names: dttp_trainee.response["firstname"],
        last_name: dttp_trainee.response["lastname"],
        address_line_one: dttp_trainee.response["address1_line1"],
        address_line_two: dttp_trainee.response["address1_line2"],
        town_city: dttp_trainee.response["address1_line3"],
        postcode: dttp_trainee.response["address1_postalcode"],
        date_of_birth: dttp_trainee.date_of_birth,
        email: dttp_trainee.response["emailaddress1"],
        gender: trainee_gender,
        trainee_id: trainee_id,
        nationalities: nationalities,
        training_route: training_route,
        trn: dttp_trainee.response["dfe_trn"],
      }.merge(ethnicity_and_disability_attributes)
    end

    def provider
      @provider ||= Provider.find_by(dttp_id: dttp_trainee.provider_dttp_id)
    end

    def placement_assignment
      @placement_assignment ||= dttp_trainee.placement_assignments.first
    end

    def trainee_already_exists?
      Trainee.exists?(dttp_id: dttp_trainee.dttp_id)
    end

    def training_route
      Dttp::CodeSets::Routes::MAPPING.select { |_key, value| value[:entity_id] == placement_assignment.route_dttp_id }.keys.first
    end

    def trainee_gender
      # TODO: Need to take a decision on mapping gender other/not provided
      # Hash#invert might not be desirable as we lose one of the duplicated values
      Dttp::Params::Contact::GENDER_CODES.invert[dttp_trainee.response["gendercode"].to_i]
    end

    def trainee_id
      return if dttp_trainee.response["dfe_traineeid"] == Dttp::Params::Contact::NOT_PROVIDED

      dttp_trainee.response["dfe_traineeid"]
    end

    def nationalities
      # TODO: We have a few different names for british and some other citizenshipss
      # ["american", "british", "cook islander", "cymraes", "cymro", "french", "israeli", "martiniquais", "mosotho", "new zealander", "puerto rican", "st helenian", "turkish"]
      Nationality.where(name: nationality_names)
    end

    def nationality_names
      [
        Dttp::CodeSets::Nationalities::MAPPING.select do |_key, value|
          value[:entity_id] == dttp_trainee.response["_dfe_nationality_value"]
        end.keys&.first,
      ]
    end

    def disability_attributes
      disability = Dttp::CodeSets::Disabilities::MAPPING.select do |_key, value|
        value[:entity_id] == dttp_trainee.response["_dfe_disibilityid_value"]
      end.keys&.first

      if disability.blank?
        return {
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided],
        }
      end

      if disability == Diversities::NO_KNOWN_DISABILITY
        return {
          diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability],
        }
      end

      # TODO: This needs a decision, since DTTP may have 'multiple disabilities'
      if disability == Diversities::MULTIPLE_DISABILITIES
        return {
          diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
          disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
          disabilities: Disability.where(name: ::Diversities::OTHER),
        }
      end

      {
        diversity_disclosure: Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed],
        disability_disclosure: Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled],
        disabilities: Disability.where(name: disability),
      }
    end

    def ethnicity_attributes
      ethnic_background = Dttp::CodeSets::Ethnicities::MAPPING.select do |_key, value|
        value[:entity_id] == dttp_trainee.response["_dfe_ethnicityid_value"]
      end.keys&.first

      ethnic_group = Diversities::BACKGROUNDS.select { |_key, values| values.include?(ethnic_background) }&.keys&.first

      diversity_disclosure = ethnic_background.present? && ethnic_background != Diversities::NOT_PROVIDED

      if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
        return {
          ethnic_background: ethnic_background,
          ethnic_group: ethnic_group,
          diversity_disclosure: diversity_disclosure,
        }
      end

      {}
    end

    def ethnicity_and_disability_attributes
      ethnicity_attributes.merge(disability_attributes)
    end
  end
end

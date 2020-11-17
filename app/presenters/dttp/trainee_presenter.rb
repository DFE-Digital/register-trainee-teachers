# frozen_string_literal: true

module Dttp
  class TraineePresenter
    attr_reader :trainee

    delegate_missing_to :trainee

    def initialize(trainee:)
      @trainee = trainee
    end

    def to_dttp_params
      {
        "firstname" => trainee.first_names,
        "lastname" => trainee.last_name,
        "contactid" => trainee.dttp_id,
        "address1_line1" => trainee.address_line_one,
        "address1_line2" => trainee.address_line_two,
        "address1_line3" => trainee.town_city,
        "address1_postalcode" => trainee.postcode,
        "birthdate" => formatted_dob,
        "emailaddress1" => trainee.email,
        "gendercode" => trainee.gender,
        "mobilephone" => trainee.phone_number,
        "_dfe_ethnicityid_value" => dttp_ethnicity_id,
        "_dfe_disibilityid_value" => dttp_disability_id,
      }
    end

  private

    def formatted_dob
      trainee.date_of_birth.strftime("%d/%m/%Y")
    end

    def dttp_ethnicity_id
      key = diversity_disclosed? ? trainee.ethnic_background : Diversities::NOT_PROVIDED
      CodeSets::Ethnicities::MAPPING.dig(key, :entity_id)
    end

    def dttp_disability_id
      key = diversity_disclosed? ? dttp_disability : Diversities::NOT_PROVIDED
      CodeSets::Disabilities::MAPPING.dig(key, :entity_id)
    end

    def dttp_disability
      if trainee_disabled?
        disabilities = trainee.disabilities.pluck(:name)
        disabilities.size == 1 ? disabilities.first : Diversities::MULTIPLE_DISABILITIES
      elsif trainee_not_disabled?
        Diversities::NO_KNOWN_DISABILITY
      else
        Diversities::NOT_PROVIDED
      end
    end

    def diversity_disclosed?
      trainee.diversity_disclosure == Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed]
    end

    def trainee_disabled?
      trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled]
    end

    def trainee_not_disabled?
      trainee.disability_disclosure == Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_disabled]
    end
  end
end

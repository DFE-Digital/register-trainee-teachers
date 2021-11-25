# frozen_string_literal: true

module Trainees
  class CreateFromDttp
    include ServicePattern

    # class MissingCourseError < StandardError; end

    def initialize(dttp_trainee:)
      @dttp_trainee = dttp_trainee
      @trainee = Trainee.new(mapped_attributes)
    end

    def call
      if trainee_already_exists?
        # TODO apply import sets the state to duplicate
        return
      end


      trainee.save!

      # TODO TBC what states are we going to use
      # dttp_record.imported!

      trainee
    end

    private

    attr_reader :dttp_trainee, :trainee

    def mapped_attributes
      # TODO flesh these out
      {
        provider: provider,
        first_names: dttp_trainee.first_name,
        last_name: dttp_trainee.last_name,
        date_of_birth: dttp_trainee.date_of_birth,
      }
      # {
      #   provider: application_record.provider,
      #   first_names: raw_trainee["first_name"],
      #   last_name: raw_trainee["last_name"],
      #   date_of_birth: raw_trainee["date_of_birth"],
      #   gender: gender,
      #   ethnic_group: ethnic_group,
      #   diversity_disclosure: diversity_disclosure,
      #   disability_disclosure: disability_disclosure,
      #   email: raw_contact_details["email"],
      #   course_uuid: course&.uuid,
      #   course_min_age: course&.min_age,
      #   course_max_age: course&.max_age,
      #   training_route: course&.route,
      #   disabilities: disabilities,
      #   study_mode: study_mode,
      # }.merge(address).merge(ethnic_background_attributes)
    end

    def provider
      Provider.find_by(dttp_id: dttp_trainee.provider_dttp_id)
    end

    def trainee_already_exists?
      Trainee.exists?(dttp_id: dttp_trainee.dttp_id)
      # Trainee.exists?(first_names: raw_trainee["first_name"],
      #                 last_name: raw_trainee["last_name"],
      #                 date_of_birth: raw_trainee["date_of_birth"])
    end
    # def create_degrees!
    #   ::Degrees::CreateFromApply.call(trainee: trainee)
    # end

    # def save_personal_details!
    #   personal_details_form.save!
    #   verify_nationalities_data!
    # end

    # def verify_nationalities_data!
    #   invalid_nationalities = raw_trainee["nationality"] - ApplyApi::CodeSets::Nationalities::MAPPING.keys

    #   return if invalid_nationalities.blank?

    #   Sentry.capture_message("Cannot map nationality from ApplyApplication id: #{application_record.id}, code: #{invalid_nationalities.join(', ')}")
    # end

    # def address
    #   raw_contact_details["country"] == "GB" ? uk_address : international_address
    # end

    # def international_address
    #   {
    #     international_address: raw_contact_details["address_line1"],
    #     locale_code: Trainee.locale_codes[:non_uk],
    #   }
    # end

    # def uk_address
    #   {
    #     address_line_one: raw_contact_details["address_line1"],
    #     address_line_two: raw_contact_details["address_line2"],
    #     town_city: raw_contact_details["address_line3"],
    #     postcode: raw_contact_details["postcode"],
    #     locale_code: Trainee.locale_codes[:uk],
    #   }
    # end

    # def gender
    #   ApplyApi::CodeSets::Genders::MAPPING[raw_trainee["gender"]] || Trainee.genders[:gender_not_provided]
    # end

    # def ethnic_group
    #   ApplyApi::CodeSets::Ethnicities::MAPPING.fetch(raw_trainee["ethnic_group"],
    #                                                  Diversities::ETHNIC_GROUP_ENUMS[:not_provided])
    # end

    # def diversity_disclosure
    #   return Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] if diversity_disclosed?

    #   Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed]
    # end

    # def disability_disclosure
    #   return Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] if disability_disclosed? && disabilities.present?
    #   return Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] if disability_disclosed? && disabilities.blank?

    #   Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided]
    # end

    # def diversity_disclosed?
    #   raw_trainee.slice("disabilities", "ethnic_group", "ethnic_background").values.any?(&:present?)
    # end

    # def disability_disclosed?
    #   raw_trainee["disability_disclosure"].present?
    # end

    # def disability_names
    #   raw_trainee["disabilities"].map { |disability| ApplyApi::CodeSets::Disabilities::MAPPING[disability] }
    # end

    # def nationality_names
    #   raw_trainee["nationality"].map do |nationality|
    #     ApplyApi::CodeSets::Nationalities::MAPPING[nationality]
    #   end
    # end


    # def ethnic_background_attributes
    #   ethnic_background = raw_trainee["ethnic_background"]

    #   return {} unless ethnic_group && ethnic_group != Diversities::ETHNIC_GROUP_ENUMS[:not_provided]
    #   return {} unless ethnic_background

    #   if Diversities::BACKGROUNDS.values.flatten.include?(ethnic_background)
    #     { ethnic_background: ethnic_background }
    #   else
    #     {
    #       ethnic_background: Diversities::ANOTHER_BACKGROUND[ethnic_group],
    #       additional_ethnic_background: ethnic_background,
    #     }
    #   end
    # end
  end
end

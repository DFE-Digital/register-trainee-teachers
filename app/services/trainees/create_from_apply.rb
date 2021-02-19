# frozen_string_literal: true

module Trainees
  class CreateFromApply
    include ServicePattern

    def initialize(json: example_json)
      @attributes = json["attributes"]
    end

    def call
      trainee.save!
      trainee
    end

  private

    attr_reader :attributes

    def example_json
      JSON.parse(example_file)
    end

    def example_file
      File.read(Rails.root.join("lib/example_apply_response.json"))
    end

    def trainee
      @trainee ||= Trainee.new(mapped_attributes)
    end

    def mapped_attributes
      {
        # TODO: Use actual provider, if found.
        provider: Provider.find(1),
        trainee_id: raw_trainee["id"],
        first_names: raw_trainee["first_name"],
        last_name: raw_trainee["last_name"],
        date_of_birth: raw_trainee["date_of_birth"],
        email: raw_contact_details["email"],
        # TODO: Use actual route type, if found.
        record_type: 1,
        programme_start_date: programme_start_date,
      }.merge(address)
    end

    def programme_start_date
      year, month = raw_course["start_date"].split("-").map(&:to_i)
      Date.new(year, month)
    end

    def address
      raw_contact_details["country"] != "GB" ? international_address : uk_address
    end

    def international_address
      {
        international_address: raw_contact_details["address_line1"],
        locale_code: 1,
      }
    end

    def uk_address
      {
        address_line_one: raw_contact_details["address_line1"],
        address_line_two: raw_contact_details["address_line2"],
        town_city: raw_contact_details["address_line3"],
        postcode: raw_contact_details["postcode"],
        locale_code: 0,
      }
    end

    def raw_trainee
      @raw_trainee ||= attributes["candidate"]
    end

    def raw_contact_details
      @raw_contact_details ||= attributes["contact_details"]
    end

    def raw_course
      @raw_course ||= attributes["course"]
    end
  end
end

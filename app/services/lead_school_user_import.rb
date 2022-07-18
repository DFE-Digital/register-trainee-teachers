# frozen_string_literal: true

class LeadSchoolUserImport
  include ServicePattern

  attr_reader :attributes

  def initialize(attributes:)
    @attributes = attributes
  end

  def call
    missing_schools = []

    attributes.each do |data|
      school = School.find_by(urn: data["URN"])

      if school.nil?
        missing_schools << data["URN"]
      else
        create_lead_school_user(school, data)
      end
    end
    missing_schools
  end

private

  def create_lead_school_user(school, data)
    user = User.create_with(first_name: data["First name"], last_name: data["Surname"])
      .find_or_create_by!(email: data["Email"])

    user.lead_schools << school unless user.lead_schools.include?(school)
  end
end

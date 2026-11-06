# frozen_string_literal: true

module SystemAdmin
  # Validates one page of the "Add a school" journey. The rules live in
  # FundingSchoolDesignationForm (and Funding::ResolveSchoolForDesignation); this
  # form runs them and keeps only the errors for the current page's question.
  class FundingSchoolDesignationStepForm
    include ActiveModel::Model

    def self.model_name = ActiveModel::Name.new(self, nil, "funding_school_designation_step_form")

    STEP_ATTRIBUTES = { "academic_year" => :academic_year, "designation" => :designation, "school" => :urn }.freeze

    attr_accessor :step, :academic_year, :designation, :school_id, :school_search
    attr_reader :school

    validate :validate_current_step

    # The URN to look up: the school chosen from the search, or a URN typed in
    # (the search box without JavaScript).
    def urn
      chosen = School.find_by(id: school_id) if school_id.present?
      chosen ? chosen.urn : school_search.to_s.strip
    end

  private

    def validate_current_step
      if step == "school" && school_id.blank? && school_search.blank?
        errors.add(:school_search, "Enter a school URN or search for a school")
        return
      end

      full = FundingSchoolDesignationForm.new(academic_year:, designation:, urn:)
      full.valid?
      @school = full.school
      attribute = STEP_ATTRIBUTES.fetch(step)
      error_attribute = attribute == :urn ? :school_search : attribute
      full.errors[attribute].each { |message| errors.add(error_attribute, message) }
    end
  end
end

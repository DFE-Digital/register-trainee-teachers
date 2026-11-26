# frozen_string_literal: true

module Schools
  # Early years teacher degree apprenticeship: the apprentice employing setting,
  # which may be a nursery without a URN. It's either found on Get information
  # about schools (GIAS), which fills in its name, town, postcode and URN, or typed in.
  class EmployingSettingForm < TraineeForm
    prepend RechecksFunding

    EDITABLE_FIELDS = %i[
      employing_school_id
      employing_school_name
      employing_school_address_line_one
      employing_school_address_line_two
      employing_school_town
      employing_school_postcode
    ].freeze

    # The URN comes from the setting found in the search, so it isn't typed in.
    FIELDS = [*EDITABLE_FIELDS, :employing_school_urn].freeze

    attr_accessor(*FIELDS)

    validates :employing_school_name, presence: true
    validates :employing_school_address_line_one, presence: true
    validates :employing_school_town, presence: true
    validates :employing_school_postcode, presence: true
    validate :postcode_valid

    def school
      return @school if defined?(@school)

      @school = (School.find_by(id: employing_school_id) if employing_school_id.present?)
    end

    def from_search?
      school.present?
    end

    # An apprentice always has an employer.
    def school_not_applicable?
      false
    end

    # Fills in the setting chosen in the search. Register doesn't hold its street address.
    def fill_in_from(school)
      @school = school
      self.employing_school_id = school.id
      self.employing_school_name = school.name
      self.employing_school_urn = school.urn
      self.employing_school_address_line_one = nil
      self.employing_school_address_line_two = nil
      self.employing_school_town = school.town
      self.employing_school_postcode = school.postcode
    end

    # The provider types the setting in, so it isn't linked to GIAS.
    def type_in
      @school = nil
      self.employing_school_id = nil
      self.employing_school_urn = nil
    end

  private

    def compute_fields
      attributes = trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
      urn = School.find_by(id: attributes[:employing_school_id])&.urn if attributes[:employing_school_id].present?
      attributes.merge(employing_school_urn: urn)
    end

    def assign_attributes_to_trainee
      super
      trainee.employing_school_not_applicable = false
    end

    def postcode_valid
      return if employing_school_postcode.blank?
      return if UKPostcode.parse(employing_school_postcode).valid?

      errors.add(:employing_school_postcode, :invalid)
    end

    def form_store_key
      :employing_school
    end
  end
end

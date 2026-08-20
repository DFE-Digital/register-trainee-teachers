# frozen_string_literal: true

module Schools
  class AssessmentOnlyEmployingSchoolForm < TraineeForm
    URN_REGEX = /^[0-9]{6}$/

    FIELDS = %i[
      employing_school_id
      employing_school_name
      employing_school_urn
      employing_school_postcode
    ].freeze

    NON_TRAINEE_FIELDS = %i[
      query
      results_search_again_query
      no_results_search_again_query
      search_results_found
      employing_school_not_applicable
    ].freeze

    attr_accessor(*(FIELDS + NON_TRAINEE_FIELDS))

    alias_method :school_id, :employing_school_id

    validates :query,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              allow_blank: true,
              if: -> { school_id.to_i.zero? && !manual_entry? }

    validate :school_present
    validates :employing_school_name, presence: true, if: :manual_entry?
    validates :employing_school_postcode, presence: true, if: :manual_entry?
    validate :urn_valid
    validate :postcode_valid, if: :manual_entry?

    def initialize(trainee, params: {}, user: nil, store: FormStore, update_trs: true)
      super
      apply_gias_or_manual
    end

    def school_name
      return if school_id.to_i.zero?

      School.find_by(id: school_id)&.name
    end

    def open_details?
      manual_entry? ||
        %i[employing_school_name employing_school_urn employing_school_postcode].intersect?(errors.attribute_names)
    end

    def needs_search_results?
      return false if school_id.to_i.positive?
      return false if manual_entry?

      search_query.length >= SchoolSearch::MIN_QUERY_LENGTH
    end

    def search_results_found?
      search_results_found == "true"
    end

    def no_results_searching_again?
      school_id == "no_results_search_again"
    end

    def training_partner_not_applicable?
      false
    end

    def employing_school_not_applicable?
      false
    end

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def apply_gias_or_manual
      if prefer_manual_entry?
        self.employing_school_id = nil
      elsif school_id.to_i.positive?
        self.employing_school_name = nil
        self.employing_school_urn = nil
        self.employing_school_postcode = nil
      elsif !results_search_id?
        self.employing_school_id = nil
      end

      fields.merge!(
        employing_school_id:,
        employing_school_name:,
        employing_school_urn:,
        employing_school_postcode:,
      )
    end

    def prefer_manual_entry?
      return false unless manual_fields_present?

      school_id.blank? || school_id.to_s == trainee.employing_school_id.to_s
    end

    def manual_fields_present?
      [employing_school_name, employing_school_urn, employing_school_postcode].any?(&:present?)
    end

    def manual_entry?
      school_id.to_i.zero? && manual_fields_present?
    end

    def results_search_id?
      %w[results_search_again no_results_search_again].include?(school_id.to_s)
    end

    def search_query
      results_search_again_query.presence || no_results_search_again_query.presence || query.to_s
    end

    def school_present
      return if school_id.to_i.positive?
      return if manual_entry?
      return if query.present?

      errors.add(:query, :blank)
    end

    def urn_valid
      return if employing_school_urn.blank?
      return if employing_school_urn.match?(URN_REGEX)

      errors.add(:employing_school_urn, :invalid_format)
    end

    def postcode_valid
      return if employing_school_postcode.blank?
      return if UKPostcode.parse(employing_school_postcode).valid?

      errors.add(:employing_school_postcode, I18n.t("activemodel.errors.validators.postcode.invalid"))
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end

    def fields_to_ignore_before_stash
      NON_TRAINEE_FIELDS
    end

    def form_store_key
      :employing_school
    end
  end
end

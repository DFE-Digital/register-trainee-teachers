# frozen_string_literal: true

module Schools
  class AssessmentOnlyEmployingSchoolForm < TraineeForm
    URN_REGEX = /^[0-9]{6}$/
    SEARCH_AGAIN_IDS = %w[results_search_again no_results_search_again].freeze
    MANUAL_FIELDS = %i[
      employing_school_name
      employing_school_urn
      employing_school_postcode
    ].freeze

    FIELDS = [:employing_school_id, *MANUAL_FIELDS].freeze

    NON_TRAINEE_FIELDS = %i[
      query
      results_search_again_query
      no_results_search_again_query
      search_results_found
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

    def school_name
      return if school_id.to_i.zero?

      School.find_by(id: school_id)&.name
    end

    def open_details?
      manual_entry? || MANUAL_FIELDS.intersect?(errors.attribute_names)
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

  private

    def compute_fields
      apply_gias_or_manual(
        trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes),
      )
    end

    # Hidden school_id after Change still matches the trainee, so manual wins.
    def apply_gias_or_manual(attrs)
      school_id = attrs[:employing_school_id]
      return attrs if SEARCH_AGAIN_IDS.include?(school_id.to_s)

      if school_id.to_i.positive? && !rely_on_manual_entry?(attrs, school_id)
        attrs.merge(MANUAL_FIELDS.index_with { nil })
      else
        attrs.merge(employing_school_id: nil)
      end
    end

    def rely_on_manual_entry?(attrs, school_id)
      return false unless MANUAL_FIELDS.any? { |field| attrs[field].present? }

      school_id.blank? || school_id.to_s == trainee.employing_school_id.to_s
    end

    def manual_entry?
      school_id.to_i.zero? && MANUAL_FIELDS.any? { |field| public_send(field).present? }
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

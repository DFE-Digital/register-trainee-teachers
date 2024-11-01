# frozen_string_literal: true

module Partners
  class Form < TraineeForm
    NON_TRAINEE_FIELDS = %i[
      query
      results_search_again_query
      no_results_search_again_query
      search_results_found
      non_search_validation
    ].freeze

    attr_accessor(*NON_TRAINEE_FIELDS)

    validates :query,
              presence: true,
              length: {
                minimum: LeadPartnerSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { lead_partner_applicable? && initial_search? }

    validates :results_search_again_query,
              presence: true,
              length: {
                minimum: LeadPartnerSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { results_searching_again? }

    validates :no_results_search_again_query,
              presence: true,
              length: {
                minimum: LeadPartnerSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { no_results_searching_again? }

    def search_results_found?
      search_results_found == "true"
    end

    def school_not_selected?
      school_applicable? && school_id.to_i.zero?
    end

    def lead_partner_not_selected?
      lead_partner_applicable? && lead_partner_id.to_i.zero?
    end

    def no_results_searching_again?
      lead_partner_id == "no_results_search_again"
    end

    def lead_partner_applicable?
      !lead_partner_not_applicable?
    end

    def lead_partner_not_applicable?
      ActiveModel::Type::Boolean.new.cast(lead_partner_not_applicable)
    end

  private

    def initial_search?
      params.key?("query")
    end

    def results_searching_again?
      lead_partner_id == "results_search_again"
    end

    def partner_id
      raise(NotImplementedError)
    end

    def lead_partner_not_applicable
      raise(NotImplementedError)
    end

    def fields_to_ignore_before_save
      NON_TRAINEE_FIELDS
    end

    def fields_to_ignore_before_stash
      NON_TRAINEE_FIELDS
    end

    def non_search_validation?
      non_search_validation == true
    end

    def lead_partner_validation_required?
      lead_partner_applicable? && (non_search_validation? || (search_results_found? && results_search_again_query.blank?))
    end
  end
end

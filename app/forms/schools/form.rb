# frozen_string_literal: true

module Schools
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
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { school_applicable? && initial_search? }

    validates :results_search_again_query,
              presence: true,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { results_searching_again? }

    validates :no_results_search_again_query,
              presence: true,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { no_results_searching_again? }

    def search_results_found?
      search_results_found == "true"
    end

    def school_not_selected?
      school_applicable? && school_id.to_i.zero?
    end

    def training_partner_not_selected?
      partner_applicable? && training_partner_id.to_i.zero?
    end

    def no_results_searching_again?
      school_id == "no_results_search_again"
    end

    def school_applicable?
      !school_not_applicable?
    end

    def school_not_applicable?
      ActiveModel::Type::Boolean.new.cast(school_not_applicable)
    end

    def partner_applicable?
      !partner_not_applicable?
    end

    def partner_not_applicable?
      ActiveModel::Type::Boolean.new.cast(partner_not_applicable)
    end

  private

    def initial_search?
      params.key?("query")
    end

    def results_searching_again?
      school_id == "results_search_again"
    end

    def school_id
      raise(NotImplementedError)
    end

    def school_not_applicable
      raise(NotImplementedError)
    end

    def partner_not_applicable
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

    def school_validation_required?
      school_applicable? && (non_search_validation? || (search_results_found? && results_search_again_query.blank?))
    end
  end
end

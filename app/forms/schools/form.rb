# frozen_string_literal: true

module Schools
  class Form < TraineeForm
    NON_TRAINEE_FIELDS = %i[
      query
      results_search_again_query
      no_results_search_again_query
      school_value
    ].freeze

    attr_accessor(*NON_TRAINEE_FIELDS)

    validates :query,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { initial_incomplete_search? }

    validates :results_search_again_query,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { results_searching_again? }

    validates :no_results_search_again_query,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: I18n.t("activemodel.errors.models.schools_form.attributes.query.length"),
              },
              if: -> { no_results_searching_again? }

    def searching_again?
      results_searching_again? || no_results_searching_again?
    end

    def results_searching_again?
      school_id == "results_search_again" || results_search_again_query.present?
    end

    def no_results_searching_again?
      school_id == "no_results_search_again"
    end

    def index_page_radio_buttons?
      school_value == "true"
    end

    def initial_incomplete_search?
      query.present? && school_id.blank?
    end

    def school_not_selected?
      searching_again? || initial_incomplete_search?
    end

  private

    def school_id
      raise NotImplementedError
    end

    def fields_to_ignore_before_stash_or_save
      NON_TRAINEE_FIELDS
    end
  end
end

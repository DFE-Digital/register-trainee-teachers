# frozen_string_literal: true

module Schools
  class Form < TraineeForm
    NON_TRAINEE_FIELDS = %i[
      results_search_again_query
      no_results_search_again_query
      school_value
    ].freeze

    attr_accessor(*NON_TRAINEE_FIELDS)

    validates :results_search_again_query, presence: true, if: -> { results_search_again_query? }
    validates :no_results_search_again_query, presence: true, if: -> { no_results_searching_again? }

    def searching_again?
      results_search_again_query? || no_results_searching_again?
    end

    def results_search_again_query?
      school_id == "results_search_again"
    end

    def no_results_searching_again?
      school_id == "no_results_search_again"
    end

    def index_page_radio_buttons?
      school_value == "true"
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

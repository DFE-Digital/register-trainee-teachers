# frozen_string_literal: true

class LeadSchoolForm < TraineeForm
  NON_TRAINEE_FIELDS = %i[
    results_search_again_query
    no_results_search_again_query
  ].freeze

  attr_accessor(*NON_TRAINEE_FIELDS, :lead_school_id)

  validates :lead_school_id, presence: true, unless: -> { searching_again? }
  validates :results_search_again_query, presence: true, if: -> { results_search_again_query? }
  validates :no_results_search_again_query, presence: true, if: -> { no_results_searching_again? }

  def searching_again?
    results_search_again_query? || no_results_searching_again?
  end

  def results_search_again_query?
    lead_school_id == "results_search_again"
  end

  def no_results_searching_again?
    lead_school_id == "no_results_search_again"
  end

private

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:lead_school_id).merge(new_attributes)
  end

  def fields_to_ignore_before_stash_or_save
    NON_TRAINEE_FIELDS
  end
end

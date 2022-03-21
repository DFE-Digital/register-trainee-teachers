# frozen_string_literal: true

module SystemAdmin
  class UserLeadSchoolsForm
    include ActiveModel::Model

    FIELDS = %i[
      query
      lead_school_id
      search_results_found
      results_search_again_query
      no_results_search_again_query
    ].freeze

    QUERY_ERROR = I18n.t("activemodel.errors.models.user_lead_schools_form.attributes.query.length")

    validates :lead_school_id, presence: true, if: :school_validation_required?

    validates :query,
              presence: true,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { initial_search? }

    validates :results_search_again_query,
              presence: true,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { results_searching_again? }

    validates :no_results_search_again_query,
              presence: true,
              length: {
                minimum: SchoolSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { no_results_searching_again? }

    attr_accessor(*FIELDS, :user)

    def save
      if valid?
        lead_school = School.find(lead_school_id)
        LeadSchoolUser.find_or_create_by!(lead_school: lead_school, user: user)
      else
        false
      end
    end

    def search_results_found?
      search_results_found == "true"
    end

    def school_not_selected?
      lead_school_id.to_i.zero?
    end

    def no_results_searching_again?
      lead_school_id == "no_results_search_again"
    end

  private

    def initial_search?
      !query.nil?
    end

    def results_searching_again?
      lead_school_id == "results_search_again"
    end

    def school_validation_required?
      search_results_found? && results_search_again_query.blank?
    end
  end
end

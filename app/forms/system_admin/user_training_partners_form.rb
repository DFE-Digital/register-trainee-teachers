# frozen_string_literal: true

module SystemAdmin
  class UserTrainingPartnersForm
    include ActiveModel::Model

    FIELDS = %i[
      query
      training_partner_id
      search_results_found
      results_search_again_query
      no_results_search_again_query
    ].freeze

    QUERY_ERROR = I18n.t("activemodel.errors.models.system_admin/user_training_partners_form.attributes.query.length")

    validates :training_partner_id, presence: true, if: :partner_validation_required?

    validates :query,
              presence: true,
              length: {
                minimum: TrainingPartnerSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { initial_search? }

    validates :results_search_again_query,
              presence: true,
              length: {
                minimum: TrainingPartnerSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { results_searching_again? }

    validates :no_results_search_again_query,
              presence: true,
              length: {
                minimum: TrainingPartnerSearch::MIN_QUERY_LENGTH,
                message: QUERY_ERROR,
              },
              if: -> { no_results_searching_again? }

    attr_accessor(*FIELDS, :user)

    def save
      if valid?
        training_partner = TrainingPartner.find(training_partner_id)
        TrainingPartnerUser.find_or_create_by!(training_partner:, user:)
      else
        false
      end
    end

    def search_results_found?
      search_results_found == "true"
    end

    def partner_not_selected?
      training_partner_id.to_i.zero?
    end

    def no_results_searching_again?
      training_partner_id == "no_results_search_again"
    end

  private

    def initial_search?
      !query.nil?
    end

    def results_searching_again?
      training_partner_id == "results_search_again"
    end

    def partner_validation_required?
      search_results_found? && results_search_again_query.blank?
    end
  end
end

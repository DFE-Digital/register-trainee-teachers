# frozen_string_literal: true

module Funding
  class TrainingInitiativesForm < TraineeForm
    FIELDS = %i[
      training_initiative
    ].freeze

    attr_accessor(*FIELDS)

    validates :training_initiative,
              presence: true,
              inclusion: { in: ROUTE_INITIATIVES_ENUMS.values },
              if: :training_initiative_required?

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :training_initiative
    end

    def training_initiative_required?
      trainee.api_record? == false && trainee.csv_record? == false
    end
  end
end

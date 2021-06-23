# frozen_string_literal: true

module Funding
  class BursaryForm < TraineeForm
    FIELDS = %i[
      applying_for_bursary
    ].freeze

    attr_accessor(*FIELDS)

    validates :applying_for_bursary, inclusion: { in: [true, false] }

  private

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :bursary
    end
  end
end

# frozen_string_literal: true

module Funding
  class BursaryForm < TraineeForm
    FIELDS = %i[
      applying_for_bursary
      bursary_tier
    ].freeze

    attr_accessor(*FIELDS)

    before_validation :set_applying_for_bursary

    validates :applying_for_bursary, inclusion: { in: [true, false] }
    validates :bursary_tier, inclusion: { in: Trainee.bursary_tiers.keys }, allow_blank: true

    def applying_for_bursary=(value)
      @applying_for_bursary = ActiveModel::Type::Boolean.new.cast(value)
    end

  private

    def set_applying_for_bursary
      self.applying_for_bursary = true if bursary_tier.present?
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :bursary
    end
  end
end

# frozen_string_literal: true

module Funding
  class BursaryForm < TraineeForm
    FIELDS = %i[
      applying_for_bursary
      bursary_tier
      tiered_bursary_form
    ].freeze

    NON_TRAINEE_FIELDS = %i[
      tiered_bursary_form
    ].freeze

    attr_accessor(*FIELDS)

    before_validation :set_applying_for_bursary

    validates :applying_for_bursary, inclusion: { in: [true, false] }
    validates :bursary_tier, inclusion: { in: Trainee.bursary_tiers.keys }, if: :requires_bursary_tier?

    def applying_for_bursary=(value)
      @applying_for_bursary = ActiveModel::Type::Boolean.new.cast(value)
    end

    def save!
      if valid?
        update_trainee_attributes
        trainee.save!
        clear_stash
      else
        false
      end
    end

  private

    def update_trainee_attributes
      # Need to save the applying_for_bursary attribute
      trainee.assign_attributes(
        fields
          .merge(applying_for_bursary: applying_for_bursary)
          .except(*fields_to_ignore_before_stash_or_save),
      )
    end

    def set_applying_for_bursary
      self.applying_for_bursary = true if bursary_tier.present?
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def form_store_key
      :bursary
    end

    def requires_bursary_tier?
      bursary_tier.present? || tier_not_selected?
    end

    def tier_not_selected?
      tiered_bursary_form.present? && bursary_tier.nil?
    end

    def fields_to_ignore_before_stash_or_save
      NON_TRAINEE_FIELDS
    end
  end
end

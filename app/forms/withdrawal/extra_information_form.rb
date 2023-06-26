# frozen_string_literal: true

module Withdrawal
  class ExtraInformationForm < TraineeForm
    FIELDS = %i[
      withdraw_reasons_details
      withdraw_reasons_dfe_details
    ].freeze

    attr_accessor(*FIELDS)

    validates :withdraw_reasons_details, length: { maximum: 500 }, allow_blank: true
    validates :withdraw_reasons_dfe_details, length: { maximum: 500 }, allow_blank: true

    def save!
      assign_attributes_to_trainee
      trainee.save
      clear_stash
    end

  private

    def form_store_key
      :withdrawal_extra_information
    end

    def compute_fields
      trainee.attributes.symbolize_keys.slice(*FIELDS).merge(new_attributes)
    end

    def new_attributes
      fields_from_store.merge(params).symbolize_keys.slice(*FIELDS)
    end
  end
end

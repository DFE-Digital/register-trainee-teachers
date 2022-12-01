# frozen_string_literal: true

class IqtsCountryForm < TraineeForm
  attr_accessor(:iqts_country, :iqts_country_raw)

  validates :iqts_country, autocomplete: true, presence: true

  def compute_fields
    trainee.attributes.symbolize_keys.slice(:iqts_country).merge(new_attributes)
  end

  def fields_to_ignore_before_save
    [:iqts_country_raw]
  end

  def fields_to_ignore_before_stash
    [:iqts_country_raw]
  end
end

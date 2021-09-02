# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider, foreign_key: :provider_code, primary_key: :code, inverse_of: :apply_applications

  validates :application, presence: true

  enum state: {
    importable: 0,
    non_importable_hei: 1,
    non_importable_duplicate: 2,
    imported: 3,
  }

  store_accessor :invalid_data, :degrees, suffix: true

  def degrees_invalid_data
    super || {}
  end

  def application_attributes
    @application_attributes ||= parsed_application["attributes"]
  end

private

  def parsed_application
    @parsed_application ||= JSON.parse(application)
  end
end

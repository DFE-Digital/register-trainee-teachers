# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider

  validates :application, presence: true

  enum state: {
    importable: 0,
    provider_a_hei: 1,
    duplicate: 2,
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

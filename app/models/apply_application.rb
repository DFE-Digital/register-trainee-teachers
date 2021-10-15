# frozen_string_literal: true

class ApplyApplication < ApplicationRecord
  belongs_to :provider, foreign_key: :accredited_body_code, primary_key: :code, inverse_of: :apply_applications, optional: true

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

  def course
    provider.courses.find_by(uuid: course_uuid) if course_uuid.present?
  end

private

  def course_uuid
    application_attributes.dig("course", "course_uuid")
  end

  def parsed_application
    @parsed_application ||= JSON.parse(application)
  end
end

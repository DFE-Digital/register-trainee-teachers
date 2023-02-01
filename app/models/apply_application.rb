# frozen_string_literal: true

# == Schema Information
#
# Table name: apply_applications
#
#  id                     :bigint           not null, primary key
#  accredited_body_code   :string
#  application            :jsonb
#  invalid_data           :jsonb
#  recruitment_cycle_year :integer
#  state                  :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  apply_id               :integer          not null
#
# Indexes
#
#  index_apply_applications_on_accredited_body_code    (accredited_body_code)
#  index_apply_applications_on_apply_id                (apply_id) UNIQUE
#  index_apply_applications_on_recruitment_cycle_year  (recruitment_cycle_year)
#
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
    @application_attributes ||= application["attributes"]
  end

  def course
    provider.courses.find_by(uuid: course_uuid) if course_uuid.present?
  end

private

  def course_uuid
    application_attributes.dig("course", "course_uuid")
  end
end

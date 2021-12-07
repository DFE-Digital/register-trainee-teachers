# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :users
  has_many :trainees

  validates :name, presence: true
  validates :dttp_id, uniqueness: true, format: { with: /\A[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}\z/i }
  validates :code, format: { with: /\A[A-Z0-9]+\z/i }, allow_blank: true

  has_many :courses, class_name: "Course", foreign_key: :accredited_body_code, primary_key: :code, inverse_of: :provider
  has_many :apply_applications, ->(provider) { unscope(:where).where(accredited_body_code: provider.code) }
  has_many :dttp_trainees, class_name: "Dttp::Trainee", foreign_key: :provider_dttp_id, primary_key: :dttp_id, inverse_of: :provider

  audited

  has_associated_audits

  def code=(cde)
    self[:code] = cde.to_s.upcase
  end

  def hpitt_postgrad?
    # TODO: An arbitrary provider set here until we receive a list of teach first providers
    code == TEACH_FIRST_PROVIDER_CODE
  end

  def name_and_code
    "#{name} (#{code})"
  end
end

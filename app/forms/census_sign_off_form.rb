# frozen_string_literal: true

class CensusSignOffForm
  include ActiveModel::Model

  validates :sign_off, presence: true, inclusion: { in: ["confirmed"] }

  def initialize(sign_off: "not_confirmed", provider: nil, user: nil)
    @sign_off = sign_off
    @provider = provider
    @user = user
  end

  def save!
    return false unless valid?

    census_sign_off = provider.sign_offs.find_or_initialize_by(academic_cycle: AcademicCycle.current, sign_off_type: :census)
    census_sign_off.user = user

    census_sign_off.save!
  end

private

  attr_reader :sign_off, :provider, :user
end

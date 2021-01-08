# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :provider

  has_many :trainees, through: :provider

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  audited

  def name
    "#{first_name} #{last_name}"
  end
end

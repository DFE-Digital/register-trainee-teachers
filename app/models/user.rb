class User < ApplicationRecord
  belongs_to :provider

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true

  def name
    "#{first_name} #{last_name}"
  end
end

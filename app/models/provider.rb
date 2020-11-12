class Provider < ApplicationRecord
  has_many :users
  has_many :trainees

  validates :name, presence: true
end

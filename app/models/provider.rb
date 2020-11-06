class Provider < ApplicationRecord
  validates :name, presence: true
end

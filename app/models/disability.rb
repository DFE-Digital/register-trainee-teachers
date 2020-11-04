class Disability < ApplicationRecord
  has_many :trainee_disabilities, inverse_of: :disability
  has_many :trainees, through: :trainee_disabilities
end

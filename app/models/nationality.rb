# frozen_string_literal: true

class Nationality < ApplicationRecord
  has_many :nationalisations, inverse_of: :nationality
  has_many :trainees, through: :nationalisations
end

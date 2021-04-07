# frozen_string_literal: true

class TraineeDisability < ApplicationRecord
  belongs_to :disability
  belongs_to :trainee

  audited associated_with: :trainee
end

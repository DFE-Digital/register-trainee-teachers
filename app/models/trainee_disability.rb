# frozen_string_literal: true

class TraineeDisability < ApplicationRecord
  belongs_to :disability
  belongs_to :trainee, touch: true

  audited associated_with: :trainee

  auto_strip_attributes :additional_disability
end

# frozen_string_literal: true

class Nationalisation < ApplicationRecord
  belongs_to :nationality
  belongs_to :trainee, touch: true

  audited associated_with: :trainee
end

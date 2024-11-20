# frozen_string_literal: true

module Trainee
  class Withdrawal < ApplicationRecord
    belongs_to :trainee

    enum trigger: { provider: 'provider', trainee: 'trainee' }, _prefix: :triggered_by
    enum future_interest: { yes: 'yes', no: 'no', unknown: 'unknown' }, _suffix: true
  end
end

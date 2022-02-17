module Dqt
  class TrnRequest < ApplicationRecord
    enum state: [ :requested, :received ]
  end
end

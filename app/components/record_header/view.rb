# frozen_string_literal: true

module RecordHeader
  class View < ApplicationComponent
    include TraineeHelper

    attr_reader :trainee, :hide_progress_tag

    def initialize(trainee:, hide_progress_tag: false)
      @trainee = trainee
      @hide_progress_tag = hide_progress_tag
    end

    delegate :trn, to: :trainee

    def show_trn?
      trn.present?
    end
  end
end

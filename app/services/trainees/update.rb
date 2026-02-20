# frozen_string_literal: true

module Trainees
  class Update
    include ServicePattern

    def initialize(trainee:, params: {}, update_trs: true)
      @trainee = trainee
      @params = params
      @update_trs = update_trs
      @trs_enabled = FeatureService.enabled?(:integrate_with_trs)
    end

    def call
      save_trainee

      enqueue_jobs

      true
    end

  private

    attr_reader :trainee, :params, :update_trs, :trs_enabled

    def save_trainee
      if params.present?
        trainee.update!(params)
      else
        trainee.save!
      end
    end

    def enqueue_jobs
      return unless valid_for_update?

      if update_trs && trs_enabled
        Trs::UpdateTraineeJob.perform_later(trainee)
        Trs::UpdateProfessionalStatusJob.perform_later(trainee)
      end
    end

    def valid_for_update?
      trainee.trn.present? && !trainee.withdrawn? && !trainee.awarded?
    end
  end
end

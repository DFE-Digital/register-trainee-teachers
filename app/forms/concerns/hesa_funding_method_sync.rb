# frozen_string_literal: true

module HesaFundingMethodSync
private

  def sync_hesa_funding_method
    return unless trainee.hesa_trainee_detail

    trainee.hesa_trainee_detail.funding_method = Trainees::MapFundingToHesa.call(trainee:)
  end
end

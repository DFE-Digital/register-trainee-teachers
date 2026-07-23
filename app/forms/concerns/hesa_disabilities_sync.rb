# frozen_string_literal: true

module HesaDisabilitiesSync
private

  def sync_hesa_disabilities
    return unless trainee.hesa_trainee_detail

    trainee.hesa_trainee_detail.hesa_disabilities = Trainees::MapDisabilitiesToHesa.call(trainee:)
  end
end

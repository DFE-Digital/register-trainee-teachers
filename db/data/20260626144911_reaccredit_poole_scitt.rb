# frozen_string_literal: true

class ReaccreditPooleScitt < ActiveRecord::Migration[8.1]
  POOLE_ACCREDITATION_ID = "5505"
  POOLE_UKPRN = "10057353"
  POOLE_PROVIDER_CODE = "P75"

  def up
    provider = Provider.find_by!(accreditation_id: POOLE_ACCREDITATION_ID, ukprn: POOLE_UKPRN, code: POOLE_PROVIDER_CODE)
    training_partner = TrainingPartner.kept.find_by!(provider_id: provider.id, ukprn: POOLE_UKPRN, record_type: TrainingPartner::SCITT)

    trainee_scope = training_partner.trainees.kept
    raise "unexpected trainees linked to another provider" if trainee_scope.where.not(provider_id: provider.id).exists?

    ActiveRecord::Base.transaction do
      provider.update!(accredited: true)

      trainee_scope.update_all(
        training_partner_id: nil,
        training_partner_not_applicable: true,
        touch: true,
      )

      training_partner.discard!
      TrainingPartnerUser.where(training_partner:).destroy_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

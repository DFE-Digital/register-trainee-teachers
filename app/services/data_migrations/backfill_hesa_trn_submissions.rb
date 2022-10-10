# frozen_string_literal: true

module DataMigrations
  class BackfillHesaTrnSubmissions
    include ServicePattern

    def call
      trn_submissions.each do |submission|
        trns = CSV.new(submission.payload, headers: true).pluck("TRN")
        next if trns.empty?

        ::Trainee.where(trn: trns).update_all(hesa_trn_submission_id: submission.id)
      end
    end

  private

    def trn_submissions
      @trn_submissions ||= ::Hesa::TrnSubmission.where.not(payload: nil)
    end
  end
end

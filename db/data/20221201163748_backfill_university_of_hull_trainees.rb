# frozen_string_literal: true

class BackfillUniversityOfHullTrainees < ActiveRecord::Migration[6.1]
  def up
    trainee_withdrawal_data = [
      { slug: "H4vg7ide5nRjxsi9TaR3SKNn", withdraw_date: "28/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "yCFgDHDFEsGUUSdLeLRyU58S", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "pADSoYbsf8s1o6M4sr1Fmii4", withdraw_date: "01/08/2022", withdraw_reason: "exclusion", additional_withdraw_reason: nil },
      { slug: "QdB3No1CP7KZuWfFCNJMnyoW", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "5R7BCLRLPGpZZURciGDwgRxi", withdraw_date: "02/10/2021", withdraw_reason: "personal_reasons", additional_withdraw_reason: nil },
      { slug: "vRJiWKuyEizM96qrDrpbyJFw", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "2BZhHKdivKYx7cjmGXNdYTek", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "ETK5JiiBzv3ccwChasmoHbT4", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "wWeqMrymvP6LL8FBWoe8HvDg", withdraw_date: "06/08/2020", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "Y9E5bnx8zuBQfmc3xD61rr6k", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "WQVpVjrxLwrFjzQSiW692Qyd", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "sWoKGUJCLora8jvJvcdsvFYL", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "HpSUSmxouzSFirKppCjXFQ1U", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "PBGC7BFUZcrbFUNoPv2XnZG4", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "kYcAqLPoz2zYiR5hUvzz9cSz", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "mcmdHjfbPQyvjAGMWKfJHirG", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "F4At1rGQiC8ZekSvaFjXdJZk", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "9guE6fvq6J4Cu2P7dQdxdYov", withdraw_date: "01/08/2021", withdraw_reason: "health_reasons", additional_withdraw_reason: nil },
      { slug: "SjVrG34pvcQWktxnKatDYnCF", withdraw_date: "25/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "go1s3jKiAYc95aGgJD57eWXt", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "iKsBGU3SbowYtHbQN3jKmKvb", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "dtMkf4maeRxMxd3XJABbWQph", withdraw_date: "01/08/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "nvdsknkfstFd6EnbcoKMtaZJ", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "bF6kgkaHAY499Yayd9j2pECY", withdraw_date: "01/09/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "hUASHmtiq3WN8p6j7cB9kJZq", withdraw_date: "01/09/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "4mCbz5axDK9jzrGJWGZodtxH", withdraw_date: "01/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "fztnZEDgjNm3M6ds51MLkHvS", withdraw_date: "02/09/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: nil },
      { slug: "K58MQv8Zsxn1yT3VGrFLgCYX", withdraw_date: "01/08/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "KqXTZafxUmTe21dP8UX6BAdY", withdraw_date: "01/08/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "NxNQYKoEj6oRJj2p2975Qmf9", withdraw_date: "13/09/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "vdxMrjaF6BBPg7fR67fcf4iy", withdraw_date: "13/09/2022", withdraw_reason: "did_not_pass_exams", additional_withdraw_reason: nil },
      { slug: "byNqRiLEe1YcXZYSMvjFN7GA", withdraw_date: "20/09/2021", withdraw_reason: "personal_reasons", additional_withdraw_reason: nil },
      { slug: "Adm2kkKiKPWWP1PcKScTCnwn", withdraw_date: "07/09/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "jeczgwVQnytHaxSVgyDvPcAi", withdraw_date: "11/10/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "rvHUiDP8czmwKtL6XwpwR9M8", withdraw_date: "14/09/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "3WervCC1dvknedpMD65RiNAr", withdraw_date: "02/09/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "1PMpNtsBEqr9Q6qzwNRdYQZ8", withdraw_date: "14/09/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "JVHi8Kz449foPhvxJD9zCpbB", withdraw_date: "01/08/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "KBffd8KedStsyMHcmzPgLrzC", withdraw_date: "24/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "9uWWicEPjvk2ECnRS5ugvLAG", withdraw_date: "20/09/2021", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "XH35fgzFuccRmMtnBWTVJH8y", withdraw_date: "21/09/2020", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
      { slug: "XK4kfVLmcirvyQmpnkj8PHph", withdraw_date: "22/08/2022", withdraw_reason: "for_another_reason", additional_withdraw_reason: "transferred to non-ITT course" },
    ]

    trainee_withdrawal_data.each do |data|
      trainee = Trainee.find_by(slug: data[:slug])

      next unless trainee

      trainee.update_columns(
        state: "withdrawn",
        withdraw_date: data[:withdraw_date].to_datetime,
        withdraw_reason: data[:withdraw_reason],
        additional_withdraw_reason: data[:additional_withdraw_reason],
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

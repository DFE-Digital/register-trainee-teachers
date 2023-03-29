# frozen_string_literal: true

class ChangeTraineeStatusesToAwarded < ActiveRecord::Migration[7.0]
  def up
    return unless Rails.env.production?

    [
      { trn: 1886203, award_date: "16/3/2023", itt_end_date: "16/3/2023" }, # NOSONAR
      { trn: 1962368, award_date: "16/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2064468, award_date: "10/3/2023", itt_end_date: "1/6/2021" }, # NOSONAR
      { trn: 2042692, award_date: "22/9/2021", itt_end_date: "22/9/2021" }, # NOSONAR
      { trn: 2142970, award_date: "15/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2142631, award_date: "15/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2059572, award_date: "15/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 1969960, award_date: "23/2/2023", itt_end_date: "23/2/2023" }, # NOSONAR
      { trn: 2144006, award_date: "23/2/2023", itt_end_date: "23/2/2023" }, # NOSONAR
      { trn: 2153713, award_date: "17/2/2023", itt_end_date: "30/12/2022" }, # NOSONAR
      { trn: 2153855, award_date: "17/2/2023", itt_end_date: "30/12/2022" }, # NOSONAR
      { trn: 2061687, award_date: "17/2/2023", itt_end_date: "30/12/2022" }, # NOSONAR
      { trn: 2142415, award_date: "23/2/2023", itt_end_date: "23/2/2023" }, # NOSONAR
      { trn: 2145930, award_date: "2/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 1889535, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2088032, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2087673, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2087660, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2088024, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2087585, award_date: "2/3/2023", itt_end_date: "2/3/2023" }, # NOSONAR
      { trn: 2086910, award_date: "7/3/2023", itt_end_date: "17/6/2022" }, # NOSONAR
      { trn: 2137710, award_date: "31/1/2023", itt_end_date: "29/6/2022" }, # NOSONAR
      { trn: 2150280, award_date: "16/2/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 4072348, award_date: "28/2/2023", itt_end_date: "28/2/2023" }, # NOSONAR
      { trn: 2084132, award_date: "20/7/2022", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2144731, award_date: "3/3/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2146143, award_date: "2/3/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2137958, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2139149, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2138765, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2138664, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2139047, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2138506, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2139054, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2138123, award_date: "24/2/2023", itt_end_date: "24/2/2023" }, # NOSONAR
      { trn: 2146875, award_date: "28/2/2023", itt_end_date: "1/6/2023" }, # NOSONAR
      { trn: 1137728, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1976554, award_date: "1/3/2023", itt_end_date: "1/6/2023" }, # NOSONAR
      { trn: 2149670, award_date: "17/2/2023", itt_end_date: "1/7/2022" }, # NOSONAR
      { trn: 2149786, award_date: "17/2/2023", itt_end_date: "1/7/2022" }, # NOSONAR
      { trn: 1836915, award_date: "17/2/2023", itt_end_date: "29/7/2022" }, # NOSONAR
      { trn: 2149685, award_date: "17/2/2023", itt_end_date: "1/7/2022" }, # NOSONAR
      { trn: 2070836, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2151247, award_date: "28/2/2023", itt_end_date: "27/1/2023" }, # NOSONAR
      { trn: 2070741, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2070763, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1981524, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2070751, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1962209, award_date: "27/2/2023", itt_end_date: "27/2/2023" }, # NOSONAR
      { trn: 1962232, award_date: "27/2/2023", itt_end_date: "27/2/2023" }, # NOSONAR
      { trn: 1982226, award_date: "23/2/2023", itt_end_date: "20/12/2022" }, # NOSONAR
      { trn: 2086733, award_date: "27/2/2023", itt_end_date: "1/4/2023" }, # NOSONAR
      { trn: 2137920, award_date: "23/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2147433, award_date: "24/2/2023", itt_end_date: "23/2/2023" }, # NOSONAR
      { trn: 2087325, award_date: "10/2/2023", itt_end_date: "30/6/2023" }, # NOSONAR
      { trn: 1937604, award_date: "11/11/2022", itt_end_date: "11/11/2022" }, # NOSONAR
      { trn: 1937381, award_date: "11/11/2022", itt_end_date: "11/11/2022" }, # NOSONAR
      { trn: 1937228, award_date: "11/11/2022", itt_end_date: "11/11/2022" }, # NOSONAR
      { trn: 2082456, award_date: "23/2/2023", itt_end_date: "27/7/2023" }, # NOSONAR
      { trn: 2082253, award_date: "23/2/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2082460, award_date: "23/2/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2142432, award_date: "23/2/2023", itt_end_date: "23/2/2023" }, # NOSONAR
      { trn: 1841132, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839271, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839270, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839269, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839268, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839267, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839266, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839264, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839260, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839257, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839256, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839254, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839253, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839252, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839251, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839250, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839249, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839248, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839247, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839246, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1841128, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839243, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839241, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839240, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839239, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 1839238, award_date: "9/2/2023", itt_end_date: "31/1/2023" }, # NOSONAR
      { trn: 2076073, award_date: "20/2/2023", itt_end_date: "1/6/2022" }, # NOSONAR
      { trn: 2042416, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
      { trn: 2084438, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
      { trn: 1888103, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
      { trn: 2083979, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
      { trn: 4060826, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
      { trn: 2155507, award_date: "15/2/2023", itt_end_date: "15/2/2023" }, # NOSONAR
    ].each do |data|
      trainee = Trainee.find_by(trn: data[:trn])

      next unless trainee

      trainee.assign_attributes(state: :awarded,
                                awarded_at: data[:award_date],
                                defer_date: nil,
                                withdraw_date: nil,
                                withdraw_reason: nil,
                                itt_end_date: data[:itt_end_date])

      trainee.save
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

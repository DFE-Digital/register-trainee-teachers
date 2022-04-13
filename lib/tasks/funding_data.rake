namespace :funding_data do
  task import_payment_profile: :environment do
    csv = CSV.parse(<<~PROFILE_DATA, headers: true)
        Academic year,Provider ID,Provider name,Description,Total funding,August,September,October,November,December,January,February,March,April,May,June,July
        2021/22,2436,Test University,Course extension trainee payments for AY 20/21,136500,33475,33475,32500,16575,20475,0,0,0,0,0,0,0
        2021/22,2436,Test University,Training bursary trainees,1531000,114214.50,114214.50,114214.50,208516.50,137790,137790,199030,137790,137790,137790,91860
        2021/22,2436,Test University,Course extension provider payments for AY 20/21,41000,,10000,9750,9875,11375,0,0,0,0,0,0,0
        2021/22,2436,Test University,Training Bursary AGR Adjustments AY18/19,-3700,,,,,-3700,0,0,0,0,0,0,0
        2021/22,2436,Test University,TB 21/22 in-year adjustment for withdrawals,-67200,,,,,-12000,-12000,0,-43200,0,0,0,0
        2021/22,2436,Test University,Training Bursary AGR Adjustments AY20/21,-6300,,,,,,,-6300,0,0,0,0,0
    PROFILE_DATA

    provider_id = 2 # get this using the Provider ID 2436 here (accreditation_id)

    provider = Provider.find(provider_id)
    payment_profile = provider.payment_profiles.create

    month_hash = { "August" => 8,
                  "September" => 9,
                  "October" => 10,
                  "November" => 11,
                  "December" => 12,
                  "January" => 1,
                  "February" => 2,
                  "March" => 3,
                  "April" => 4,
                  "May" => 5,
                  "June" => 6,
                  "July" => 7 }

    csv.each do |row|
      payment_profile_row = payment_profile.rows.create(description: row["Description"])
      month_hash.each do | month_name, month_index |
        year = month_index > 7 ? 2021 : 2022 # this needs to be worked out from first col on CSV
        predicted = [5,6,7].include?(month_index) ? true : false # there is nothing in CSV to indicate actual or predicted months, so here we are taking last three months as predicted
        payment_profile_row.amounts.create(
          month: month_index,
          year: year,
          amount_in_pence: row[month_name].to_d * 100,
          predicted: predicted
        )
      end
    end
  end
end

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

    #this task can probably be used for the lead school version (SDS) but we'll need to get the lead school instead of provider
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

  task import_trainee_payment_summary: :environment do
    csv = CSV.parse(<<~BREAKDOWN_DATA, headers: true)
        Provider,Provider name,Academic Year,Subject,Route,Lead School,Lead School ID,Cohort Level,Bursary Amount,Bursary Trainees,Scholarship Amount,Scholarship Trainees,Tier 1 Amount,Tier 1 Trainees,Tier 2 Amount,Tier 2 Trainees,Tier 3 Amount,Tier 3 Trainees
        5638,Happy Schools SCITT,2021/22,Physics,Provider-led,,,PG,24000,2,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,English,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Mathematics,Provider-led,,,PG,24000,1,26000,1,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Modern Languages,Provider-led,,,PG,2,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Business studies,Provider-led,,,PG,0,0,18000,5,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Chemistry,Provider-led,,,PG,20000,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Art & design,School Direct tuition fee,Deyes High School,137533,PG,0,0,28000,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,History,School Direct tuition fee,Deyes High School,137533,PG,15000,6,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Computing,School Direct tuition fee,Deyes High School,137533,PG,0,0,10000,4,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Primary,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Physical education,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Geography,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Design & technology,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Primary with mathematics,Provider-led,,,PG,20000,3,30000,2,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Religious education,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Drama,Provider-led,,,PG,0,0,0,0,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Biology,Provider-led,,,PG,18000,4,12000,2,0,0,0,0,0,0
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate employment-based,,,PG,0,0,0,0,15000,1,10000,0,8000,0
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate employment-based,,,PG,0,0,0,0,15000,0,10000,0,8000,0
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate employment-based,,,PG,0,0,0,0,15000,0,10000,4,8000,1
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate Entry,,,PG,0,0,0,0,15000,2,10000,0,8000,0
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate Entry,,,PG,0,0,0,0,15000,0,10000,0,8000,0
        5638,Happy Schools SCITT,2021/22,Early Years ITT,EYITT Graduate Entry,,,PG,0,0,0,0,15000,1,10000,2,8000,0
    BREAKDOWN_DATA

    provider_id = 2 # get this using the Provider ID 5638 here (accreditation_id) also lead school as above

    provider = Provider.find(provider_id)
    trainee_payment_summary = provider.trainee_payment_summaries.create(academic_year: "2021/22")  # fish the year out of the CSV. All rows will be the same

    summary_row_maps = [
      {amount: "Bursary Amount", trainees: "Bursary Trainees", payment_type: "bursary", tier: nil},
      {amount: "Scholarship Amount", trainees: "Scholarship Trainees", payment_type: "scholarship", tier: nil},
      {amount: "Tier 1 Amount", trainees: "Tier 1 Trainees", payment_type: "bursary", tier: 1},
      {amount: "Tier 2 Amount", trainees: "Tier 2 Trainees", payment_type: "bursary", tier: 2},
      {amount: "Tier 3 Amount", trainees: "Tier 3 Trainees", payment_type: "bursary", tier: 3},
    ]

    csv.each do |row|
      trainee_payment_summary_row = trainee_payment_summary.rows.create(
        subject: row["Subject"],
        route: row["Route"],
        lead_school_name: row["Lead School"],
        lead_school_urn: row["Lead School ID"],
        cohort_level: row["Cohort Level"],
      )

      summary_row_maps.each do |summary_row_map|
        #NB these will be strings when we fish 'em out of the CSV
        number_of_trainees = row[summary_row_map[:trainees]]
        amount = row[summary_row_map[:amount]]
        if (number_of_trainees && number_of_trainees.to_d > 0) && (amount && amount.to_d > 0)
          trainee_payment_summary_row.amounts.create(
            amount: amount,
            number_of_trainees: number_of_trainees,
            payment_type: summary_row_map[:payment_type],
            tier: summary_row_map[:tier],
          )
        end
      end
    end
  end
end

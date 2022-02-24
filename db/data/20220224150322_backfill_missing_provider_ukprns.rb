# frozen_string_literal: true

class BackfillMissingProviderUkprns < ActiveRecord::Migration[6.1]
  def up
    {
      9 => 10035411,
      10 => 10007152,
      13 => 10055363,
      15 => 10007806,
      16 => 10045988,
      18 => 10037587,
      24 => 10004930,
      28 => 10002327,
      32 => 10007140,
      33 => 10007811,
      35 => 10000840,
      37 => 10001143,
      40 => 10046623,
      41 => 10034267,
      43 => 10046861,
      45 => 10002718,
      50 => 10003678,
      51 => 10003863,
      52 => 10003956,
      53 => 10004048,
      55 => 10055240,
      57 => 10004351,
      59 => 10007832,
      65 => 10008026,
      66 => 10006299,
      73 => 10035578,
      81 => 10004797,
      86 => 10007787,
      87 => 10007137,
      88 => 10007144,
      89 => 10007146,
      90 => 10007149,
      91 => 10007802,
      92 => 10007159,
      93 => 10007163,
      96 => 10000712,
      97 => 10007848,
      98 => 10007842,
      99 => 10007851,
      100 => 10007143,
      101 => 10007145,
      102 => 10007147,
      103 => 10001282,
      104 => 10007158,
      105 => 10003614,
      106 => 10007166,
      107 => 10046788,
      108 => 10005145,
      116 => 10066301,
      118 => 10027700,
      119 => 10057399,
      121 => 10054033,
    }.each do |provider_id, ukprn|
      Provider.find(provider_id).update(ukprn: ukprn)
    end

    # Fix data for existing provider.
    # It's currently pointing to St Mary's University, Belfast instead of St Mary's University, Twickenham
    Provider.find_by(ukprn: 10008026).update(dttp_id: "9b407223-7042-e811-80ff-3863bb3640b8", ukprn: 10007843)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

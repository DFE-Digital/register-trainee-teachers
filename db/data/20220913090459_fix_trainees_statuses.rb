# frozen_string_literal: true

class FixTraineesStatuses < ActiveRecord::Migration[6.1]
  def up
    # Remove duplicate trainee
    Trainee.find_by(hesa_id: 2010289040732).destroy

    Trainee.find_by(trn: 2038203).update_columns(awarded_at: "08/01/2022")
    Trainee.find_by(trn: 2068721).update_columns(state: :withdrawn, withdraw_reason: WithdrawalReasons::DEATH)

    [1754063, 1836859, 1859242, 1960177, 2042122, 2048081, 2052341, 2066594, 1685644].each do |trn|
      Trainee.find_by(trn: trn).update_columns(state: :deferred)
    end

    [
      1762487,
      1835292,
      1864698,
      1884607,
      1888638,
      1966925,
      2054894,
      2059657,
      2060113,
      2061178,
      2062470,
      2062917,
      2064931,
      2070993,
      1689943,
      1761094,
      1761095,
      1761122,
      1771045,
      1775109,
      1781954,
      1837480,
      1837499,
      1837618,
      1837690,
      1845175,
      1845313,
      1856545,
      1857659,
      1865064,
      1960548,
      1961598,
      1966215,
      2044816,
      2048979,
      2051560,
      2059354,
      2068007,
      2068012,
      2068023,
      4047434,
      1760850,
    ].each do |trn|
      Trainee.find_by(trn: trn).update_columns(state: :withdrawn, withdraw_reason: WithdrawalReasons::UNKNOWN)
    end

    [
      1770486,
      1858777,
      1860368,
      1860987,
      1967024,
      1774608,
      1858875,
      1867828,
      1962157,
      1963961,
      1971980,
      2035938,
      2044848,
      2046855,
      2047769,
      2049347,
      2049850,
      2057587,
      2058026,
      2063417,
    ].each do |trn|
      Trainee.find_by(trn: trn).update_columns(state: :trn_received)
    end

    [
      { trn: 1840459, awarded_at: "16/12/2021" },
      { trn: 1840785, awarded_at: "10/09/2021" },
      { trn: 2055596, awarded_at: "05/01/2022" },
      { trn: 2056550, awarded_at: "05/01/2022" },
      { trn: 1758285, awarded_at: "10/09/2021" },
    ].each do |data|
      Trainee.find_by(trn: data[:trn]).update_columns(awarded_at: data[:awarded_at])
    end

    [
      { trn: 1850688, new_trn: 2071387, awarded_at: "09/07/2021" },
      { trn: 2043058, new_trn: 1073116, awarded_at: "24/06/2011" },
      { trn: 2047124, new_trn: 1982622, awarded_at: "25/03/2020" },
      { trn: 2049539, new_trn: 1976919, awarded_at: "19/11/2019" },
      { trn: 2068161, new_trn: 2072954, awarded_at: "16/07/2021" },
      { trn: 2070906, new_trn: 2072030, awarded_at: "17/12/2021" },
    ].each do |data|
      Trainee.find_by(trn: data[:trn]).update_columns(trn: data[:new_trn], awarded_at: data[:awarded_at])
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

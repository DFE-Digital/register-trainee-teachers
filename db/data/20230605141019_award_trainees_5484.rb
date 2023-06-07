# frozen_string_literal: true

class AwardTrainees5484 < ActiveRecord::Migration[7.0]
  def up
    [["Yo2HN696rsFZcr6QhbQdSXuh", "28/04/2023"],
     ["e87sEGusLaRWJbVojpaPhuX8", "28/04/2023"],
     ["yWiQqPSNjSsRxW3pRJBE84Xo", "28/04/2023"],
     ["HyXkwxsVJrhykyQKLr52fSAj", "21/02/2023"],
     ["XnocJPNfyGAhjw5r45eXFYCs", "12/05/2023"],
     ["V9Lq4yZ6xmLrJTnhMFds9QGe", "20/04/2023"],
     ["AAjhizhmthc2byX5VjimjtfC", "05/05/2023"],
     ["uoqVuiLjPFfcdpppB77FzBoP", "05/05/2023"],
     ["r1fkRNgyosGhsKqDYYzWWvP8", "05/05/2023"],
     ["3BTWmHXzsPGf8HtEF8WSqX1R", "05/05/2023"],
     ["m2jMN2wgnLBf9mHbH32S2wX1", "01/05/2023"],
     ["45RCSTPymJT8VxXCSpLkHFAb", "02/05/2023"],
     ["cVKRakpdu3Qi4iZzfDaRaUDL", "20/04/2023"],
     ["QyjQYHGFZAYDBPcVBnqwqYE6", "25/04/2023"],
     ["A7NiuiXhCrch6crNSwvA9hz2", "05/04/2023"],
     ["fjwHHhYDooSq7WLEtobatsGM", "20/04/2023"],
     ["WVis9nAUKXNKTbbJTxL5yEyL", "03/03/2023"],
     ["M9hycTtDx39ogmLD7SyY5uha", "17/04/2023"],
     ["JggKLU8LxF4MkuS6C31SDyMW", "17/04/2023"],
     ["TaULD8FBZKxQdoFVsWB2oTGy", "17/04/2023"],
     ["dSHdXSXjEC5De4WKoyPcjP4i", "17/04/2023"],
     ["xPkReGszXqv6LdAnTvTmdtMp", "21/04/2023"],
     ["pwxNmbB9mMat878gWepEo2vu", "18/04/2023"],
     ["C1eZavSRUmszsaLTJoJWEcNQ", "18/04/2023"],
     ["AfRxCnXguhhxkuwcpqKDcB4o", "18/04/2023"],
     ["d8S9bZVDpFLZiRmU59jqyKEq", "18/04/2023"],
     ["ry2mHaurYpd1TXbimBNQtuoJ", "18/04/2023"],
     ["XDdXsAirznSAdVDnmB8NoeFm", "18/04/2023"],
     ["rgVnuQ6vHDiFNbbBY7znTLmx", "18/04/2023"],
     ["ZM3bhHCagvvjELEWJJLHRpwY", "18/04/2023"],
     ["z9L1Xj53o4QGaXV6y62fRgDi", "18/04/2023"],
     ["Es8yRW2nR72wmmUjMoeXBwWX", "18/04/2023"],
     ["YQDaz3zYboPsMk2UAHVPJ1fu", "18/04/2023"],
     ["p7dGDcmSs1DRxPfJJb9BU7N4", "18/04/2023"],
     ["ZTmB7uGtNuQceLuNeLqJd9MC", "18/04/2023"],
     ["di52mdL7wpLtfbtmYSH3g643", "19/04/2023"],
     ["Dk33Bdq7GAedXfkv8WbJGReH", "18/04/2023"],
     ["ZqL9TR993QexvieS5RVKk1j3", "17/04/2023"]].each do |slug, awarded_at|
      trainee = Trainee.find_by(slug:)
      next unless trainee

      trainee.assign_attributes(state: :awarded, awarded_at: DateTime.parse(awarded_at), defer_date: nil, withdraw_date: nil)
      trainee.save!
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

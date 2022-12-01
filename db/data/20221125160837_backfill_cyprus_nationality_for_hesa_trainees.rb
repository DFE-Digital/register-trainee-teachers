# frozen_string_literal: true

class BackfillCyprusNationalityForHesaTrainees < ActiveRecord::Migration[6.1]
  def up
    trainee_slugs = %w[HMpx9gnWFi6F9Ly1gDhE9s4M
                       MUozuNAGH9JagVXDc2Ug6KmK
                       yPJQwC9MV9SZBuLy6wCUtU4P
                       Jjg7aL7hSbEEj3eHUzZHyhBw
                       AUtftGGgGPxU5P8KBD3zVpMm
                       swkip8c7sDn5KWbcgGcEraC1
                       7rNc9FbPWPW4ZqGRk9f9xLq1
                       4PbhFvi6hWDoyHDt5gjBZJ64
                       LWAjcAn25UoEL5JrTUAUrZvZ
                       1nmBBzzAhgQzuEGtwWvvRY4K
                       aYs192hH2eo2gb9M1qfFr9Xu
                       j5kxXR83MPdHcX2EqPF4KvKg
                       nSij7nDthp1dohW9hjMs1H4T
                       atkEWxJrjKC1W7ampwVa6Tkd
                       ZTyNbFGd72SA4zxhRADdDX17
                       QAQsLzF3PvuQH85Rpx1TCHSx
                       LmSv3kSRd3NKTTLyF1V7bwrs
                       dqxeHjMXfByxPJuStmvXjgi3
                       M58XSGXHspYYHmtTh6zJdXZM
                       SayMCZstFxdjQiYe9Mjzm6sh
                       6H78owDosf8CZsKz1CDoSAJV
                       FKLG6UYjjLRSj1upzioqyEpN]

    eu_cypriot = Nationality.find_by(name: "cypriot (european union)")

    return unless eu_cypriot

    trainee_slugs.each do |slug|
      trainee = Trainee.find_by(slug: slug)

      if trainee
        Nationalisation.find_or_create_by!(trainee_id: trainee.id, nationality_id: eu_cypriot.id)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

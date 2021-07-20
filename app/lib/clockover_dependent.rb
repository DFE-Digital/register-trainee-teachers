# frozen_string_literal: true

module ClockoverDependent
  def before_clockover?
    Time.zone.now < clockover_date
  end

  def clockover_date
    Time.zone.parse(Settings.clockover_date)
  end
end

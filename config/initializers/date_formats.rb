# frozen_string_literal: true

# https://www.gov.uk/guidance/style-guide/a-to-z-of-gov-uk-style#dates
Date::DATE_FORMATS[:govuk]         = Time::DATE_FORMATS[:govuk]         = "%-d %B %Y" # 2 January 1998
Date::DATE_FORMATS[:govuk_no_year] = Time::DATE_FORMATS[:govuk_no_year] = "%-d %B"    # 2 January
Date::DATE_FORMATS[:govuk_short]   = Time::DATE_FORMATS[:govuk_short]   = "%-d %b %Y" # 2 Jan 1998
Date::DATE_FORMATS[:govuk_approx]  = Time::DATE_FORMATS[:govuk_approx]  = "%B %Y"     # January 1998
Date::DATE_FORMATS[:govuk_slash]   = Time::DATE_FORMATS[:govuk_slash]   = "%d/%m/%Y"  # 30/01/1998

Time::DATE_FORMATS[:govuk_date_and_time] = lambda do |time|
  format = if time.between?(time.midday, time.midday.end_of_minute)
             "%e %B %Y at %l%P (midday)"
           elsif time.between?(time.midnight, time.midnight.end_of_minute)
             "%e %B %Y at %l%P (midnight)"
           else
             "%e %B %Y at %l:%M%P"
           end

  time.in_time_zone("London").strftime(format).squeeze(" ").lstrip
end

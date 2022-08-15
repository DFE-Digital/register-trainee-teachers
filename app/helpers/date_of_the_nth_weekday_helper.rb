# frozen_string_literal: true

module DateOfTheNthWeekdayHelper
  def date_of_nth_weekday(month, year, weekday, nth)
    base_date = Date.new(year, month)
    weekday_of_the_first_of_the_month = base_date.wday
    ret_date = base_date +
      (weekday > weekday_of_the_first_of_the_month ? weekday - weekday_of_the_first_of_the_month : 7 - weekday_of_the_first_of_the_month + weekday) +
      (7 * (nth - 1))
    ret_date.month == month ? ret_date : nil
  end
end

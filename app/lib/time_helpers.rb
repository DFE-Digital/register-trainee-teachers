# frozen_string_literal: true

module TimeHelpers
  def in_exact_time(datetime, from = Time.current)
    datetime = datetime.to_date if datetime.respond_to?(:to_date)
    from = from.to_date if from.respond_to?(:to_date)

    return unless datetime > from

    days = (datetime - from).to_i

    if (months = months_between(from, datetime))
      "in #{months} #{'month'.pluralize(months)}"
    elsif days >= 7 && (days % 7).zero?
      weeks = days / 7
      "in #{weeks} #{'week'.pluralize(weeks)}"
    else
      "in #{days} #{'day'.pluralize(days)}"
    end
  end

private

  def months_between(from, datetime)
    months = ((datetime.year - from.year) * 12) + (datetime.month - from.month)

    return if months < 1 || from + months.months != datetime

    months
  end
end

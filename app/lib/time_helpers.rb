# frozen_string_literal: true

module TimeHelpers
  def in_exact_time(datetime, from = Time.current)
    datetime = datetime.to_date if datetime.respond_to?(:to_date)
    from = from.to_date if from.respond_to?(:to_date)

    return unless datetime > from

    days = (datetime - from).to_i

    if (months = months_between(from, datetime))
      "in #{months} month#{'s' if months != 1}"
    elsif days >= 7 && days % 7 == 0
      weeks = days / 7
      "in #{weeks} week#{'s' if weeks != 1}"
    else
      "in #{days} day#{'s' if days != 1}"
    end
  end

private

  def months_between(from, datetime)
    (1..12).find { |n| from + n.months == datetime }
  end
end

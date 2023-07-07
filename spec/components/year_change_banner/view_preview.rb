# frozen_string_literal: true

class YearChangeBanner::ViewPreview < ViewComponent::Preview
  def default_state
    Timecop.freeze(Date.new(Time.zone.today.year, 6, 1)) do
      render(YearChangeBanner::View.new)
    end
  end

  def july
    Timecop.freeze(Date.new(Time.zone.today.year, 7, 1)) do
      render(YearChangeBanner::View.new)
    end
  end

  def august
    Timecop.freeze(Date.new(Time.zone.today.year, 8, 1)) do
      render(YearChangeBanner::View.new)
    end
  end
end

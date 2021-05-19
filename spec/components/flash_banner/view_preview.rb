# frozen_string_literal: true

module FlashBanner
  class ViewPreview < ViewComponent::Preview
    def with_success
      render(FlashBanner::View.new(flash: flash(:success), trainee: trainee))
    end

    def with_warning
      render(FlashBanner::View.new(flash: flash(:warning), trainee: trainee))
    end

    def with_info
      render(FlashBanner::View.new(flash: flash(:info), trainee: trainee))
    end

  private

    def trainee
      Trainee.new(id: 1, state: :submitted_for_trn)
    end

    def flash(type)
      flash = ActionDispatch::Flash::FlashHash.new
      flash[type] = "Trainee #{type}"
      flash
    end
  end
end

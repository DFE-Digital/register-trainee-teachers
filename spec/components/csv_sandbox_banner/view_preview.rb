# frozen_string_literal: true

class CsvSandboxBanner::ViewPreview < ViewComponent::Preview
  def show_csv_sandbox_banner
    render(CsvSandboxBanner::View.new(show_csv_sandbox_banner: true))
  end

  def not_show_csv_sandbox_banner
    render(CsvSandboxBanner::View.new(show_csv_sandbox_banner: false))
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe SortLinks::View do
  alias_method :component, :page

  before do
    allow(controller).to receive(:params).and_return(params)
    render_inline(described_class.new)
  end

  let(:params) { ActionController::Parameters.new({}) }
  let(:date_updated_link_text) { t("components.page_titles.trainees.sort_links.date_updated") }
  let(:last_name_link_text) { t("components.page_titles.trainees.sort_links.last_name") }

  context "no query params" do
    it "has text date updated" do
      expect(component).to_not have_link(date_updated_link_text, href: "/?sort_by=date_updated")
      expect(component).to have_text(date_updated_link_text)
    end

    it "has a link to sort by last name" do
      expect(component).to have_link(last_name_link_text, href: "/?sort_by=last_name")
    end
  end

  context "query params has sort_by=date_updated" do
    let(:params) { ActionController::Parameters.new({ sort_by: :date_updated }) }

    it "changes the date_updated link to text only" do
      expect(component).to have_text(date_updated_link_text)
      expect(component).to_not have_link(date_updated_link_text, href: "/?sort_by=date_updated")
    end

    it "continues to render the last_name link" do
      expect(component).to have_link(last_name_link_text, href: "/?sort_by=last_name")
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::RouteIndicator::View do
  alias_method :component, :page

  let(:trainee) { create(:trainee) }

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  describe "rendered component" do
    it "renders the correct training route link" do
      expect(component).to have_link(href: "/trainees/#{trainee.slug}/training-routes/edit")
    end
  end

  describe "no rendered component" do
    let(:trainee) { create(:trainee, :submitted_for_trn) }

    it "wont render if the trainee is not a draft trainee" do
      expect(component).to have_no_content
    end
  end
end

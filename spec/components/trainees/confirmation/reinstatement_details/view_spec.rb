# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trainees::Confirmation::ReinstatementDetails::View do
  include SummaryHelper

  alias_method :component, :page

  let(:trainee) { build(:trainee, :reinstated, id: 1) }

  before do
    render_inline(described_class.new(trainee: trainee))
  end

  it "renders the date the trainee was reinstated" do
    expect(component).to have_text(date_for_summary_view(trainee.reinstate_date))
  end
end

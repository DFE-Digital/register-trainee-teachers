# frozen_string_literal: true

require "rails_helper"

describe ReinstatementDetails::View do
  include SummaryHelper

  let(:trainee) { build(:trainee, :reinstated, id: 1) }
  let(:data_model) { OpenStruct.new(trainee: trainee, date: trainee.reinstate_date) }

  before do
    render_inline(described_class.new(data_model))
  end

  it "renders the date the trainee was reinstated" do
    expect(rendered_component).to have_text(date_for_summary_view(data_model.date))
  end
end

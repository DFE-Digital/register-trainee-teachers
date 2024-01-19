# frozen_string_literal: true

require "rails_helper"

RSpec.describe SelectPlacementSchoolForm, type: :model do
  include ActionView::Helpers::SanitizeHelper

  subject(:form) { described_class.new(trainee: trainee, query: "Reading") }

  let(:trainee) { double("Trainee", slug: "trainee0001") }

  describe "validations" do
    it { is_expected.to validate_presence_of(:school_id) }
  end
end

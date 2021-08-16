# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe School, type: :model do
    subject { create(:dttp_school) }

    it { is_expected.to have_db_index(:dttp_id) }

    describe ".active" do
      let(:active_dttp_school) { create(:dttp_school, :active) }

      subject { described_class.active }

      before do
        active_dttp_school
        create(:dttp_school)
      end

      it "returns only active schools" do
        expect(subject.count).to eq(1)
        expect(subject).to include(active_dttp_school)
      end
    end
  end
end

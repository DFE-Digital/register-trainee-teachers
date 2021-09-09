# frozen_string_literal: true

require "rails_helper"

module Dttp
  describe School, type: :model do
    subject { create(:dttp_school) }

    it { is_expected.to have_db_index(:dttp_id) }

    describe ".active" do
      subject { described_class.active }

      context "when a school is active" do
        let(:school) { create(:dttp_school, :active) }

        it "is returned" do
          expect(subject).to include(school)
        end
      end

      context "when a school is new" do
        let(:school) { create(:dttp_school, :new) }

        it "is returned" do
          expect(subject).to include(school)
        end
      end

      context "when a school is neither" do
        let(:school) { create(:dttp_school, :inactive) }

        it "is not returned" do
          expect(subject).not_to include(school)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Timeline
    describe View do
      alias_method :component, :page

      let(:trainee) { create(:trainee, trait) }
      let!(:user) { create(:user, provider: trainee.provider) }

      before do
        render_inline(described_class.new(trainee))
      end

      shared_examples "created" do
        it "shows when the record was created" do
          expect(component).to have_text("Record created")
        end
      end

      shared_examples "submitted for trn" do
        it "shows when the record was submitted for trn" do
          expect(component).to have_text("Trainee submitted for TRN")
        end
      end

      describe "when the trainee state is" do
        context "created" do
          let(:trait) { :draft }
          include_examples "created"
        end

        context "submitted for trn" do
          let(:trait) { :submitted_for_trn }
          include_examples "created"
          include_examples "submitted for trn"
        end
      end
    end
  end
end

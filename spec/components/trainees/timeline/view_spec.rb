# frozen_string_literal: true

require "rails_helper"

module Trainees
  module Timeline
    describe View do
      alias_method :component, :page

      let(:trainee) { create(:trainee) }

      describe "when the trainee state is" do
        context "created" do
          before do
            render_inline(described_class.new(trainee))
          end
          it "shows when the record was created" do
            expect(component).to have_text(expected_title(:created))
          end
        end

        context "submitted for trn" do
          before do
            trainee.submit_for_trn!
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until submitted_for_trn" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
          end
        end

        context "trn_received" do
          before do
            methods = %i[submit_for_trn! receive_trn!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until trn_received" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
          end
        end

        context "recommended_for_qts" do
          before do
            methods = %i[submit_for_trn! receive_trn! recommend_for_qts!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until recommended_for_qts" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
            expect(component).to have_text(expected_title(:recommended_for_qts))
          end
        end

        context "withdrawn" do
          before do
            methods = %i[submit_for_trn! receive_trn! withdraw!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until withdrawn" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
            expect(component).to have_text(expected_title(:withdrawn))
          end
        end

        context "deferred" do
          before do
            methods = %i[submit_for_trn! receive_trn! defer!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until deferred" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
            expect(component).to have_text(expected_title(:deferred))
          end
        end

        context "reinstated" do
          before do
            methods = %i[submit_for_trn! receive_trn! defer! receive_trn!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end
          it "shows state changes until reinstated" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
            expect(component).to have_text(expected_title(:deferred))
            expect(component).to have_text(expected_title(:reinstated))
          end
        end

        context "qts_awarded" do
          before do
            methods = %i[submit_for_trn! receive_trn! recommend_for_qts! award_qts!]
            call_methods!(methods, trainee)
            render_inline(described_class.new(trainee))
          end

          it "shows state changes until qts_awarded" do
            expect(component).to have_text(expected_title(:created))
            expect(component).to have_text(expected_title(:submitted_for_trn))
            expect(component).to have_text(expected_title(:trn_received))
            expect(component).to have_text(expected_title(:qts_awarded))
          end
        end
      end

      # Helper method to transfer the trainee through the various states in
      # order.
      def call_methods!(methods, trainee)
        methods.each_with_object(trainee) do |method, t|
          t.public_send(method)
          t
        end
      end

      def expected_title(value)
        I18n.t("components.timeline.titles.#{value}")
      end
    end
  end
end
